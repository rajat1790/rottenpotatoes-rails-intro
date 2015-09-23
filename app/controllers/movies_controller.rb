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
    @all_ratings = Movie.uniq.pluck(:rating)
    @var = false
    # Get the remembered settings
    if (params[:ratings] == nil and params[:id] == nil and
              (session[:ratings] != nil or session[:id] != nil))
      if (params[:id] == nil and session[:id] != nil)
        params[:id] = session[:id]
      elsif(params[:ratings] == nil and session[:ratings] != nil)
	params[:ratings] = session[:ratings]
      end
      flash.keep
      redirect_to movies_path(:id => params[:id], :ratings => params[:ratings])
    else
      
      @selected_ratings = @all_ratings
      if(params[:ratings] == nil)
	params[:ratings] = session[:ratings]
	if(session[:ratings])
          @selected_ratings = session[:ratings].keys
	  @var = true
	end
      else
	@selected_ratings = params[:ratings].keys
      end
      if(params[:id] == nil)
	params[:id] = session[:id]
      end
      if(@var)
	flash.keep
	redirect_to movies_path(:id => params[:id], :ratings => params[:ratings])
      end
      session[:id] = params[:id]
      session[:ratings] = params[:ratings]
      if (params[:id] == "title_header") # Sort by titles
	@title_header = "hilite"
        if (params[:ratings]) # filter ratings
          @movies = Movie.where(rating: @selected_ratings).order(:title)
        else
          @movies = Movie.order(:title)
        end
      elsif (params[:id] == "release_date_header") # Sort by release_date
	@release_date = "hilite"
        if (params[:ratings]) # filter ratings
          @movies = Movie.where(rating: @selected_ratings).order(:release_date)
        else
          @movies = Movie.order(:release_date)
        end
      elsif (params[:id] == nil)
        if (params[:ratings] or session[:ratings]) # filter ratings
          @movies = Movie.where(rating: @selected_ratings)
        else
          @movies = Movie.all
        end
      end
    end
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
