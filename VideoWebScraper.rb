#-------------------------------------------------------------
require 'csv' # needed for HubTrafficManagerCreator

class HubTrafficManagerCreator
  attr_accessor :rating, :age, :valueArray, :duration, :comments, :tags, :categories, :url, :username, :title, :star, :upVotes, :downVotes, :totalViews

  def initialize
    @contentGrabber = ContentGrabber.new
  end

  def createManagerCSVFile(fileName, delimiterChar)
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
    @valueArray = valuesArray
    @url = @valueArray[0]
    @categories = @valueArray[1] == nil ?  @valueArray[1] : @valueArray[1].split(';')
    @rating = @valueArray[2].to_i
    @username = @valueArray[3]
    @title = @valueArray[4]
    @tags = @valueArray[5] == nil ?  @valueArray[5] : @valueArray[5].split(';')
    @duration = @valueArray[6].to_i
    @star = @valueArray[7]
    grabbedContent = @contentGrabber.grabContent(@url)
    @comments = grabbedContent[0]
    @totalViews = grabbedContent[1]
    @upVotes = grabbedContent[2]
    @downVotes = grabbedContent[3]
    @age = grabbedContent[4]
  end
end

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
end

#-------------------------------------------------------------
require 'rubygems' # needed for ContentGrabber because using a gem
require 'nokogiri' # needed for ContentGrabber becuase using nokogiri
require 'open-uri' # needed for ContentGrabber because remote source

class ContentGrabber
  def extractMessage(commentMsgDiv)
    message = commentMsgDiv.css("div")[1].to_s.strip

    message = message[5, message.length - 11]

    imgArray = commentMsgDiv.css("img[alt]")

    smileyArray = Array.new
    imgLineArray = Array.new

    if(imgArray != nil )
      imgArray.each{|line|
        imgLineArray << line.to_s.strip
        smiley = line.to_s.split("alt=\"")[1]
        smileyArray << smiley[0, smiley.length-2]
      }
    end

    i = 0
    limit = imgLineArray.length
    while(i < limit)
      message = message.sub(imgLineArray[i], smileyArray[i])

      i = i + 1
    end

    message = message.gsub( "<br>" , "\n")

    return message
  end

  def grabContent(url)
    doc = Nokogiri::HTML(open(url))

    comments = Array.new

    commentsShown = doc.css("section#allComments").css("li.parent")

    commentsShown.each{ |comment|
      name = comment.css("div.usernameWrap").css("a").text

      message = self.extractMessage(comment.css("div.commentMsg"))

      upVotes = comment.css("var.voteNumUp").text.to_i

      downVotes = comment.css("var.voteNumDown").text.to_i

      age = comment.css("span.commentAge").text

      replies = Array.new
      replyNum = 0

      comment.css("li.child-reply").each{|reply|
        replyNum = replyNum + 1

        replyName = reply.css("div.usernameWrap").css("a").text

        replyMessage = self.extractMessage(reply.css("div.commentMsg"))

        replyUpVotes = reply.css("var.voteNumUp").text.to_i

        replyDownVotes = reply.css("var.voteNumDown").text.to_i

        replyAge = reply.css("span.commentAge").text

        replies << ReplyComment.new(replyName, replyMessage, replyUpVotes, replyDownVotes, replyAge, replyNum)

      }

      comments << Comment.new(name, message, upVotes, downVotes, age, replies)
    }

    totalViews = doc.css("div.rating-info-container").css("span.count").text

    upVotes = doc.css("div.votes-count-container").css("span.votesUp").text

    downVotes = doc.css("div.votes-count-container").css("span.votesDown").text

    age = doc.css("div.video-info-row").css("span.white")[0].text

    return [comments, totalViews, upVotes, downVotes, age]
  end
end

#-------------------------------------------------------------
class CSVCreatorVisitor
  def initialize(fileName)
    @fileNameCSV = fileName
    @currentVideoArray = Array.new
    @currentCommentArray = Array.new
    @currentReplyArray = Array.new
  end

  def visitReplyComment(comment)
    @currentReplyArray = [comment.name, comment.message, comment.upVotes, comment.downVotes, comment.age, comment.replyNumber]
  end

  def visitVideo(video)
    @currentVideoArray = [video.url, video.categories, video.rating, video.username, video.title, video.tags, video.duration, video.star, video.age, video.totalViews, video.upVotes, video.downVotes] #need to change later if scarping more info
    video.comments.each{ |comment|
    comment.accept(self)
      @currentVideoArray = @currentVideoArray.concat(@currentCommentArray)
    }
  end

  def visitComment(comment)
    @currentCommentArray = [comment.name, comment.message, comment.upVotes, comment.downVotes, comment.age, comment.replys.length]
    comment.replys.each{ |reply|
      reply.accept(self)
      @currentCommentArray = @currentCommentArray.concat(@currentReplyArray)
    }
  end

  def visitVideoManager(manager)
    CSV.open(@fileNameCSV, 'w') do |csvObject|
      headerRow = ["URL", "Categories", "Rating", "Username of Uploader", "Title of Video", "Tags", "Duration in Seconds", "Pornstar Names", "Age of Video", "Total Views", "Up Votes", "Down Votes", "Commententor Name", "Comment Message", "Comment Up Votes", "Comment Down Votes", "Age of Comment", "Number of Replys", "..." ]
      csvObject << headerRow
      i = 0
      videoNum = manager.getVideoNum
      while i < videoNum
        manager.getVideo(i).accept(self)
        csvObject << @currentVideoArray
        i = i + 1
      end
    end
  end

  def changeFileName(fileName)
    @fileNameCSV = fileName
  end
end

#-------------------------------------------------------------
h = HubTrafficManagerCreator.new
csv = CSVCreatorVisitor.new("")

fileNames = []

fileNames.each{ |fileName|
  puts fileName + " is now starting."

  m = h.createManagerCSVFile(fileName, '|')

  newFileName = fileName.split('.')[0] + " Completed.csv"

  csv.changeFileName(newFileName)
  m.accept(csv)

  puts newFileName + " has now been created."
  puts "----"
}
