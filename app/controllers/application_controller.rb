class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_ref, :set_maybe_ref

  # Homepage action
  def index
    @offers = api.form("joboffers").submit(@ref)
    @areas_by_id = api.form("everything").query('[[:d = at(document.type, "area")]]').submit(@ref).group_by{|doc| doc.id}
  end

  def offer
    id = params[:id]
    @offer = PrismicService.get_document(id, api, @ref)
    @area = PrismicService.get_document(@offer['joboffer.area'].id, api, @ref)
  end

  def newoffer
    @article = PrismicService.get_document(api.bookmark("newoffer"), api, @ref)
  end
  

  private


  ## before_action methods

  # Setting @ref as the actual ref id being queried, even if it's the master ref.
  # To be used to call the API, for instance: api.form('everything').submit(@ref)
  def set_ref
    @ref = params[:ref].blank? ? api.master_ref.ref : params[:ref]
  end

  # Setting @maybe_ref as the ref id being queried, or nil if it is the master ref.
  # To be used where you want nothing if on master, but something if on another release.
  # For instance:
  #  * you can use it to call Rails routes: document_path(ref: @maybe_ref), which will add "?ref=refid" as a param, but only when needed.
  #  * you can pass it to your link_resolver method, which will use it accordingly.
  def set_maybe_ref
    @maybe_ref = (params[:ref] != '' ? params[:ref] : nil)
  end

  ##

  # Easier access and initialization of the Prismic::API object.
  def api
    @access_token = session['ACCESS_TOKEN']
    @api ||= PrismicService.init_api(@access_token)
  end

end
