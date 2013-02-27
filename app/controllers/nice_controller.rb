require 'net/http'

class NiceController < ApplicationController
  
  DEFAULT_FAMILY = "vanilla"
  SPECIAL_FAMILY = "5.0"
  
  def index
    #call Onchilada
    Thread.new{onchilada_homepage()}.join  
  end
  
  def vanilla
    width = params[:width]
    height = params[:height]
    family = DEFAULT_FAMILY
    handleimage(width, height, family)
  end
  
  def vanillasquare
    width = params[:square]
    height = params[:square]
    family = DEFAULT_FAMILY
    handleimage(width, height, family)    
  end
  
  def fivepointoh
    width = params[:width]
    height = params[:height]
    family = SPECIAL_FAMILY
    handleimage(width, height, family)      
  end
  
  def fivepointohsquare
    width = params[:square]
    height = params[:square]
    family = SPECIAL_FAMILY
    handleimage(width, height, family)    
  end
  
  private 
  
  def onchilada_homepage
    Net::HTTP.get(URI.parse('http://api.onchilada.com/tick/homepage/nicenicejpg'))
  end
  
  def onchilada_image
    Net::HTTP.get(URI.parse('http://api.onchilada.com/tick/jpg/nicenicejpg'))
  end
  
  def handleimage(w, h, family)
    
      desiredWidth = w.to_i > 1001 ? 1001 : w.to_i
      desiredHeight = h.to_i > 1001 ? 1001 : h.to_i
      
      #determine if landscape or portrait is being requested
      orientation = (desiredWidth >= desiredHeight) ? "landscape" : "portrait"
      
      #get a pic
      pic = choosepic(desiredWidth.to_i, desiredHeight.to_i, orientation, family)
      
      #open and resize the image
      image = Magick::Image.read(File.expand_path("../../pics/#{family}/#{orientation}/#{pic}.jpg", __FILE__)).first
      image.resize_to_fill!(desiredWidth.to_i, desiredHeight.to_i)
      image_as_blob = image.to_blob { self.quality=50 }
      
      #call Onchilada
      Thread.new{onchilada_image()}.join
      
      #set headers and send the data
      response.headers["Cache-Control"] = "max-age=31622400"
      response.headers["Expires"] = 1.year.from_now.httpdate
      send_data image_as_blob, :type => "image/jpeg", :disposition => "inline"
  end
  
  def choosepic(desiredWidth, desiredHeight, orientation, family)
    if family == DEFAULT_FAMILY
      if orientation == "landscape"
        if desiredWidth <= 300
          pic = 1
        elsif desiredWidth <= 450
          pic = 2
        elsif desiredWidth <= 600
          pic = 3
        elsif desiredWidth <= 1000
          pic = 4
        else
          pic = 5
        end
      elsif orientation == "portrait"
        if desiredWidth <= 250
          pic = 1
        elsif desiredWidth <= 450
          pic = 2
        elsif desiredWidth <= 600
          pic = 3
        else
          pic = 4
        end
      end
    elsif family == SPECIAL_FAMILY
      if orientation == "landscape"
        if desiredWidth <= 300
          pic = 1
        elsif desiredWidth <= 600
          pic = 2
        else
          pic = 3
        end
      elsif orientation == "portrait"
        if desiredWidth <= 300
          pic = 1
        elsif desiredWidth <= 600
          pic = 2
        else
          pic = 3
        end
      end
    end
  end
end