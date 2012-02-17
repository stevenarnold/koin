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
end
