require_relative 'CVSCreatorVisitor.rb'
require_relative 'HubPageScraper'
require_relative 'CVSCreatorVisitor.rb'
require_relative 'TextAntConcCreatorVisitor.rb'
require_relative 'VideoWebScraperMainClasses'

#-------------------------------------------------------------
require 'csv' # needed for HubTrafficManagerCreatorToo

class HubTrafficManagerCreatorToo
  attr_accessor :rating, :age, :valueArray, :duration, :comments, :tags, :categories, :url, :username, :title, :star, :upVotes, :downVotes, :totalViews

  def initialize
    @comments = Array.new
  end

  def createVideoManager(fileName)
    @comments = Array.new
    count = 1
    videoManager = VideoManager.new
    CSV.foreach(fileName) do |row|
      if(count < 102 && count > 1)
        parseValueArray(row)
        videoManager.addVideo(Video.new(self))
      end
      count = count + 1
    end
    return videoManager
  end

  def parseValueArray(valuesArray)
    length = valuesArray.length
    count = 12
    while (length > count)
      replyComments = Array.new
      commentMessage = valuesArray[count + 1]
      count = count + 6
      numReplys = valuesArray[count - 1].to_i
      i = 0
      while(i < numReplys)
        replyComments << ReplyComment.new(nil,valuesArray[count + 1],nil,nil,nil,nil)
        count += 6
        i += 1
      end
      @comments << Comment.new(nil,commentMessage,nil,nil,nil,replyComments)

    end
  end
end


#-------------------------------------------------------------
hubTrafficCreator = HubTrafficManagerCreatorToo.new
textVisitor = TextAntConcCreatorVisitor.new("")

fileNames = ["amateur Completed.csv"] #["anal Completed.csv", "asain Completed.csv", "babe Completed.csv", "bbw Completed.csv", "bear Completed.csv", "big ass Completed.csv", "big dick Completed.csv", "big tits Completed.csv", "bisexual Completed.csv", "black Completed.csv", "blonde Completed.csv", "blowjob Completed.csv", "bondage Completed.csv", "brunette Completed.csv", "bukkake Completed.csv", "camel toe Completed.csv", "celebrity Completed.csv", "college Completed.csv", "compilation Completed.csv", "creampie Completed.csv", "cumshots Completed.csv", "daddy Completed.csv", "double penetration Completed.csv", "ebony Completed.csv", "euro Completed.csv", "facial Completed.csv", "fetish Completed.csv", "fisting Completed.csv", "for women Completed.csv", "funny Completed.csv", "gangbang Completed.csv", "gay Completed.csv", "group Completed.csv", "handjob Completed.csv", "hardcore Completed.csv", "hentai Completed.csv", "hunks Completed.csv", "indian Completed.csv", "interracial Completed.csv", "japanese Completed.csv", "latina Completed.csv", "latino Completed.csv", "lesbian Completed.csv", "massage Completed.csv", "masturbation Completed.csv", "milf Completed.csv", "muscle Completed.csv", "orgy Completed.csv", "outdoor Completed.csv", "party Completed.csv", "pornstar Completed.csv", "pov Completed.csv", "public Completed.csv", "reality Completed.csv", "red head Completed.csv", "rough sex Completed.csv", "sex Completed.csv", "shemale Completed.csv", "small tits Completed.csv", "solo male Completed.csv", "squirt Completed.csv", "straight guys Completed.csv", "striptease Completed.csv", "teen Completed.csv", "threesome Completed.csv", "toys Completed.csv", "twink Completed.csv", "uniforms Completed.csv", "vintage Completed.csv", "webcam Completed.csv"]
fileNames.each{ |fileName|
  puts fileName + " is now starting."

  videoManager = hubTrafficCreator.createVideoManager(fileName)

  newFileName = fileName.split('.')[0] + " Text.txt"
  textVisitor.changeFileName(newFileName)

  #
  videoManager.accept(textVisitor)

  puts newFileName + " has now been created."
  puts "----"
}
