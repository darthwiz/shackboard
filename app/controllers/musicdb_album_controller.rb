class MusicdbAlbumController < ApplicationController
  before_filter :authenticate
  def list # {{{
    order = params[:order] || 'none'
    unless [:title, :author, :publisher, :user_id].include?(order.to_sym)
      order = 'title'
    end
    order << ", author, title, publisher, user_id"
    @albums = MusicdbAlbum.find(:all, :order => order)
  end # }}}
  def new # {{{
  end # }}}
  def edit # {{{
  end # }}}
  def create # {{{
    album = MusicdbAlbum.new { |a|
      a.title     = params[:musicdb_album][:title]
      a.author    = params[:musicdb_album][:author]
      a.publisher = params[:musicdb_album][:publisher]
      a.user_id   = session[:userid]
    }
    if (album.save)
      flash[:notice] = 'Album inserito correttamente.'
      redirect_to :action => 'new'
    else
      flash[:error] = "Errore nell'inserimento dell'album."
      redirect_to :action => 'new'
    end
  end # }}}
  def update # {{{
  end # }}}
end
