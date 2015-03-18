#-------------------------------------------------------------
require 'rubygems' # needed for ContentGrabber because using a gem
require 'nokogiri' # needed for ContentGrabber becuase using nokogiri
require 'open-uri' # needed for ContentGrabber because remote source

class HubPageScraper
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
