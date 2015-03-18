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