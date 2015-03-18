#-------------------------------------------------------------
class Video
    attr_accessor :rating, :duration, :comments, :tags, :categories, :url, :username, :title, :star, :age, :upVotes, :downVotes, :totalViews

    def initialize(informationKnower)
        self.grabInfo(informationKnower)
    end

    def grabInfo(informationKnower)
        @url = informationKnower.url
        @categories = informationKnower.categories
        @rating = informationKnower.rating
        @username = informationKnower.username
        @title = informationKnower.title
        @tags = informationKnower.tags
        @duration = informationKnower.duration
        @star = informationKnower.star
        @comments = informationKnower.comments
        @totalViews = informationKnower.totalViews
        @upVotes = informationKnower.upVotes
        @downVotes = informationKnower.downVotes
        @age = informationKnower.age
    end

    def accept(visitor)
        visitor.visitVideo(self)
    end
end

#-------------------------------------------------------------
class Comment
    attr_accessor :age, :name, :upVotes, :message, :downVotes, :replys

    def initialize(name, message, upVotes, downVotes, age, replys)
        @name = name
        @message = message
        @upVotes = upVotes
        @downVotes = downVotes
        @age = age
        @replys = replys
    end

    def accept(visitor)
        visitor.visitComment(self)
    end
end

#-------------------------------------------------------------
class ReplyComment #Reply comments cannot have replies :)
    attr_accessor :age, :name, :upVotes, :message, :downVotes, :replyNumber

    def initialize(name, message, upVotes, downVotes, age, replyNum)
        @name = name
        @message = message
        @upVotes = upVotes
        @downVotes = downVotes
        @age = age
        @replyNumber = replyNum
    end

    def accept(visitor)
        visitor.visitReplyComment(self)
    end
end


#-------------------------------------------------------------
class VideoManager #maybe do something more elaborate...
    def initialize
        @videoList = Array.new
    end

    def addVideo(video)
        @videoList << video
    end

    def accept(visitor)
        visitor.visitVideoManager(self)
    end

    def getNumberOfVideos
        return @videoList.length
    end

    def getVideo(i)
        return @videoList[i]
    end

end

