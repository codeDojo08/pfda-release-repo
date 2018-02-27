class AssetsController < ApplicationController
  skip_before_action :require_login,     only: [:index, :featured, :explore, :show, :new]
  before_action :require_login_or_guest, only: [:index, :featured, :explore, :show, :new]
  def index
    if @context.guest?
      redirect_to explore_assets_path
      return
    end

    # Refresh state of assets, if needed
    User.sync_assets!(@context)

    # Wice seems to not like the default_scope of Asset
    assets = Asset.unscoped.editable_by(@context)
    @assets_grid = initialize_grid(assets.includes(:taggings),{
      name: 'assets',
      order: 'user_files.name',
      order_direction: 'asc',
      per_page: 100,
      include: [:user, {user: :org}, {taggings: :tag}]
    })
  end

  def featured
    org = Org.featured
    if org
      assets = Asset.unscoped.accessible_by(@context).joins(:user).where(:users => { :org_id => org.id })

      @assets_grid = initialize_grid(assets.includes(:taggings),{
        name: 'assets',
        order: 'user_files.name',
        order_direction: 'asc',
        per_page: 100,
        include: [:user, {user: :org}, {taggings: :tag}]
      })
    end
    render :index
  end

  def explore
    assets = Asset.unscoped.accessible_by_public
    @assets_grid = initialize_grid(assets.includes(:taggings),{
      name: 'assets',
      order: 'user_files.name',
      order_direction: 'asc',
      per_page: 100,
      include: [:user, {user: :org}, {taggings: :tag}]
    })
    render :index
  end

  def new
  end

  def show
    @asset = Asset.accessible_by(@context).includes(:archive_entries).find_by!(dxid: params[:id])

    # Refresh state of asset, if needed
    if @asset.state != "closed"
      User.sync_asset!(@context, @asset.id)
      @asset.reload
    end

    @items_from_params = [@asset]
    @item_path = pathify(@asset)
    @item_comments_path = pathify_comments(@asset)
    @comments = @asset.root_comments.order(id: :desc).page params[:comments_page]

    @notes = @asset.notes.accessible_by(@context).order(id: :desc).page params[:notes_page]
    @answers = @asset.notes.accessible_by(@context).answers.order(id: :desc).page params[:answers_page]
    @discussions = @asset.notes.accessible_by(@context).discussions.order(id: :desc).page params[:discussions_page]

    if @asset.editable_by?(@context)
      @licenses = License.editable_by(@context)
    end

    js asset: @asset.slice(:id, :description), license: @asset.license ? @asset.license.slice(:uid, :content) : nil
  end

  def edit
    @asset = Asset.editable_by(@context).includes(:archive_entries).find_by!(dxid: params[:id])

    js asset: @asset.slice(:id, :description)
  end

  def rename
    @asset = Asset.editable_by(@context).find_by!(dxid: params[:id])
    title = asset_params[:title]
    if title.is_a?(String) && title != ""
      name = title + @asset.suffix
      if @asset.rename(name, @context)
        @asset.reload
        flash[:success] = "Asset renamed to \"#{@asset.name}\""
      else
        flash[:error] = "Asset \"#{@asset.name}\" could not be renamed."
      end
    else
      flash[:error] = "The new name is not a valid string"
    end

    redirect_to asset_path(@asset.dxid)
  end

  def update
    @asset = Asset.editable_by(@context).includes(:archive_entries).find_by!(dxid: params[:id])

    Asset.transaction do
      @asset.reload
      if @asset.update(asset_params)
        # Handle a successful update.
        flash[:success] = "Asset updated"
        redirect_to asset_path(@asset.dxid)
      else
        flash[:error] = "Error: Could not update the asset. Please try again."
        render 'edit'
      end
    end
  end

  def destroy
    @file = Asset.editable_by(@context).find_by!(dxid: params[:id])

    UserFile.transaction do
      @file.reload

      if @file.license.present? && !@file.apps.empty?
        flash[:error] = "This asset contains a license, and has been included in one or more apps. Deleting it would render the license inaccessible to these apps, breaking reproducibility. You can either first remove the license (allowing these existing apps to run without requiring a license) or contact the precisionFDA team to discuss other options."
        redirect_to asset_path(@file.dxid)
        return
      end
      @file.destroy
    end

    DNAnexusAPI.new(@context.token).call(@file.project, "removeObjects", objects: [@file.dxid])

    flash[:success] = "Asset \"#{@file.prefix}\" has been successfully deleted"
    redirect_to assets_path
  end

  private

  def asset_params
    params.require(:asset).permit(:description, :title)
  end
end
