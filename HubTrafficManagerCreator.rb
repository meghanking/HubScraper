require 'csv'

class HubTrafficManagerCreator
    attr_accessor :rating, :age, :duration, :comments, :tags, :categories, :url, :username, :title, :star, :upVotes, :downVotes, :totalViews

    def initialize
        @contentGrabber = HubPageScraper.new
    end

    def createVideoManager(fileName, delimiterChar)
        count = 0
        videoManager = VideoManager.new
        CSV.foreach(fileName) do |row|
            puts row.to_s
            row = row.join(",")
            row = row.split('|')
            if(count < 100)
                parseValueArray(row)
                videoManager.addVideo(Video.new(self))
                count = count + 1
            end
        end
        return videoManager
    end

    def parseValueArray(valuesArray)
        @url = valuesArray[0]
        @categories = valuesArray[1] == nil ?  valuesArray[1] : valuesArray[1].split(';')
        @rating = valuesArray[2].to_i
        @username = valuesArray[3]
        @title = valuesArray[4]
        @tags = valuesArray[5] == nil ?  valuesArray[5] : valuesArray[5].split(';')
        @duration = valuesArray[6].to_i
        @star = valuesArray[7]
        grabbedContent = @contentGrabber.grabContent(@url)
        @comments = grabbedContent[0]
        @totalViews = grabbedContent[1]
        @upVotes = grabbedContent[2]
        @downVotes = grabbedContent[3]
        @age = grabbedContent[4]
    end
end