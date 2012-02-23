class KoinController < ApplicationController
  def uploadFile
    @df = DataFile.new
    @df.capture_file(params[:upload])
    @df.save
    respond_to do |format|
      format.html {
        render :index
      }
    end
  end
  
  def download
    # Download a file by token
    @token = params[:token]
    @df = DataFile.where("digest LIKE ?", @token)[0]
    if @df && @df.digest.length == 32
      send_file @df.path, type: "application/octet-stream"
    else
      respond_to do |format|
        format.html {
          render :index
        }
      end
    end
  end
end
