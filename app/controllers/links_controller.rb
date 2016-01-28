class LinksController < ApplicationController

require 'link_thumbnailer'
  around_filter :set_time_zone
  before_action :set_links, only: [:show, :edit, :update, :destroy]

  def home
    @intakeurl = params[:intake]
    # @time ||= browser_timezone if browser_timezone.present?
  end

  def index
  	@intakeurl ||= params[:intake]

    if @intakeurl[0, 11] == "http://www."
      @intakeurl ||= params[:intake]
    elsif @intakeurl[0, 4] == "www."
      @intakeurl = "http://#{@intakeurl}"
    elsif @intakeurl[0, 5] == "https"
      lastint = @intakeurl.bytesize - 1
      @intakeurl = "http#{@intakeurl[5..lastint]}"
    elsif @intakeurl[0, 7] == "http://"
      lastint = @intakeurl.bytesize - 1
      @intakeurl = "http://www.#{@intakeurl[7..lastint]}"
    else
      @intakeurl = "http://www.#{@intakeurl}"
    end

    @preview = LinkThumbnailer.generate(@intakeurl)
    @link = Link.new

    @todaynyesterday = Link.where(user_id: current_user.id, created_at: (DateTime.now.to_date-1).beginning_of_day .. DateTime.now.end_of_day)
    @thisweek = Link.where(user_id: current_user.id, created_at: (DateTime.now.to_date-6).beginning_of_day .. (DateTime.now.to_date-2).end_of_day)
    @longtimeago = Link.where(user_id: current_user.id, created_at: (DateTime.now.to_date-3000).beginning_of_day .. (DateTime.now.to_date-7).end_of_day)
  end

  def suggestion
    @shared = Link.where("share like ?", "%#{current_user.email}%" )    
  end

  def create
  	@link = Link.new(link_params)
  	if @link.save
  		redirect_to link_path(@link), notice: "You will be receiving your reminder email this weekend!"
  	else
  		render :new
  	end
  end

  def destroy
    @link.destroy
    redirect_to links_view_path
  end

  def edit
  end

  def show
    verification = Link.find(params["id"])
    if verification.user_id == current_user.id
      @link = verification
    else
      redirect_to root_path, notice: "Your record does not exist. Please refer to your library."
    end
  end

  def view
    links = Link.search_for(params[:q])
    @todaynyesterday = links.where(user_id: current_user.id, created_at: (DateTime.now.to_date-1).beginning_of_day .. DateTime.now.end_of_day)
    @thisweek = links.where(user_id: current_user.id, created_at: (DateTime.now.to_date-6).beginning_of_day .. (DateTime.now.to_date-2).end_of_day)
    @longtimeago = links.where(user_id: current_user.id, created_at: (DateTime.now.to_date-3000).beginning_of_day .. (DateTime.now.to_date-7).end_of_day)
    @shared = Link.where("share like ?", "%#{current_user.email}%" )
  end

  def share
    @group_search = User.search_for(params[:user])   
  end

  def update
    if @link.update(link_params)
      redirect_to link_path(@link), notice: "Your update has been reflected to our server."
    else
      render :edit
    end
  end

  private

  def link_params
  	params.require(:link).permit(:url, :title, :content, :image, :reminder, :share).merge(user_id: current_user.id)
  end

  def set_time_zone
    old_time_zone = Time.zone
    Time.zone = browser_timezone if browser_timezone.present?
    @time = Time.zone
    yield
  ensure
    Time.zone = old_time_zone
  end
                                                                                 
  def browser_timezone
    cookies["browser.timezone"]
  end

  def set_links
    begin
      @link = Link.find(params[:id])
    rescue
      redirect_to root_path, notice: "The link that you requested earlier does not exist in our database."
    end
  end

end
