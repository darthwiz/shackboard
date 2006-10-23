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
    @musicdb_album = MusicdbAlbum.find(params[:id])
    unless (@musicdb_album)
      redirect_to :action => 'list'
    end
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
    album = MusicdbAlbum.find(params[:id])
    if (album && album.user_id == session[:userid])
      album.title     = params[:musicdb_album][:title]
      album.author    = params[:musicdb_album][:author]
      album.publisher = params[:musicdb_album][:publisher]
      album.save
    end
    redirect_to :action => 'list'
  end # }}}
end
