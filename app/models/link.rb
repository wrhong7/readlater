class Link < ActiveRecord::Base
	belongs_to :user

	validates_presence_of :url, :title, :content
	validates :title, length: {minimum: 3}
	
	def self.search_for(query)
		where('url LIKE :query OR title LIKE :query OR content LIKE :query', query: "%%#{query}%")
	end

end
