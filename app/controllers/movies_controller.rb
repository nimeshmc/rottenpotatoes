class MoviesController < ApplicationController
  def initialize()
    @all_ratings = Movie.all_ratings
    @checked_boxes = Hash.new(true)
    super
  end
  
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    if !session[:ratings]
      session[:ratings] = Hash.new(true)
      @all_ratings.each do |rating|
        session[:ratings][rating] = '1'
      end
    end
    if params[:ratings]
        session[:ratings] = params[:ratings]
    end
    if params[:sort]
      session[:sort] = params[:sort]
    end
    if (!params[:sort] and session[:sort]) or !params[:ratings]
      if flash[:notice]
        flash.keep
      end
      redirect_to(movies_path({:sort => session[:sort], :ratings => session[:ratings]}))
    end
    if (session[:sort] == 'title')
      @movies = Movie.find(:all, :conditions => ["rating in (?)", session[:ratings].keys], :order => 'title')
      @title_header_class = 'hilite'
      @release_date_header_class = ''
    elsif (session[:sort] == 'release_date')
      @movies = Movie.find(:all, :conditions => ["rating in (?)", session[:ratings].keys], :order => 'release_date')
      @release_date_header_class = 'hilite'
      @title_header_class = ''
    else
      @movies = Movie.find(:all, :conditions => ["rating in (?)", session[:ratings].keys])
      @title_header_class = ''
      @release_date_header_class = ''
    end
    @all_ratings.each do |rating|
      @checked_boxes[rating] = session[:ratings].include?(rating)
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
