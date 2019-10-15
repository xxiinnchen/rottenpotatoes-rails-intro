class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # part 1
    sort_by = params[:sort] || session[:sort]
    if sort_by == 'title'
      @title_header = 'hilite'
    end
    if sort_by == 'release_date'
      @release_date_header = 'hilite'
    end

    # part2
    @all_ratings = Movie.all_ratings
    @filter_ratings = params[:ratings] || session[:ratings] || {}

    if @filter_ratings == {}
      @filter_ratings = Hash[@all_ratings.map {|rating| [rating, rating]}]
    end

    #part 3 remeber with session
    if session[:sort] != params[:sort]
      session[:sort] = params[:sort]
      flash.keep
      redirect_to :sort => sort_by, :ratings => @filter_ratings and return
    end

    if session[:ratings] != params[:ratings] and @filter_ratings != {}
      session[:ratings] = params[:ratings]
      session[:sort] = session[:sort]
      flash.keep
      redirect_to :sort => sort_by, :ratings => @filter_ratings and return
    end

    @movies = Movie.where(rating: @filter_ratings.keys).order(sort_by)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
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
