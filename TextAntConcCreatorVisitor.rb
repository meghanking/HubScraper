class TextAntConcCreatorVisitor
    def initialize(fileName)
        @fileNameText = fileName
        @commentArray = Array.new
    end

    def visitReplyComment(comment)
        @commentArray << comment
    end

    def visitVideo(video)
        video.comments.each{ |comment|
            comment.accept(self)
        }
    end

    def visitComment(comment)
        @commentArray << comment
        comment.replys.each{ |reply|
            reply.accept(self)
        }
    end

    def visitVideoManager(manager)
        videoNum = manager.getNumberOfVideos
        i = 0
        while i < videoNum
            manager.getVideo(i).accept(self)
            i = i+1
        end
        # write all stuff to file
        File.open( @fileNameText , 'w' ) do |file|
            @commentArray.each { |comment|
                file.puts comment.message
                file.puts "."
            }
        end
    end

    def changeFileName(fileName)
        @fileNameText = fileName
    end
end