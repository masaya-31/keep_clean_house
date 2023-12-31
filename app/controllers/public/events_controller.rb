class Public::EventsController < ApplicationController
  before_action :authenticate_member!
  before_action :ensure_correct_member, only: [:edit, :update, :destroy, :show]

  def index
    @events = current_member.events
    # 今日以降の予定を一覧表示
    @event_lists = current_member.events.where("start_time >= ?", Date.today).order(start_time: :asc)
  end

  def new
    @event = Event.new
    favorites = Favorite.where(member_id: current_member.id).pluck(:post_id)
    @favorite_posts = Post.find(favorites)
  end

  def show
    @event = Event.find(params[:id])
  end

  def create
    @event = Event.new(event_params)
    # 参考記事の選択
    post_choice

    if @event.save
      flash[:color] = "text-success"
      redirect_to events_path, notice: 'イベントを作成しました'
    else
      favorites = Favorite.where(member_id: current_member.id).pluck(:post_id)
      @favorite_posts = Post.find(favorites)
      render :new
    end
  end

  def edit
    @event = Event.find(params[:id])
    favorites = Favorite.where(member_id: current_member.id).pluck(:post_id)
    @favorite_posts = Post.find(favorites)
  end

  def update
    @event = Event.find(params[:id])
    # 参考記事の選択
    post_choice

    if @event.update(event_params)
      flash[:color] = "text-success"
      redirect_to events_path, notice: 'イベントを編集しました'
    else
      favorites = Favorite.where(member_id: current_member.id).pluck(:post_id)
      @favorite_posts = Post.find(favorites)
      render :edit
    end
  end

  def destroy
    event = Event.find(params[:id])
    if event.destroy
      flash[:color] = "text-danger"
      redirect_to events_path, notice: "イベントを削除しました"
    else
      redirect_to events_path, notice: "イベントの削除に失敗しました"
    end
  end

  private

  def event_params
    params.require(:event).permit(:title, :start_time, :member_id, :post_id, :select_post)
  end

  # current_memberか判断する
  def ensure_correct_member
    event = Event.find(params[:id])
    member = event.member
    unless member.id == current_member.id
      redirect_to events_path
    end
  end

  # 参考記事の選択
  def post_choice
    if params[:event][:select_post] == 'no_post'
      @event.post_id = -1
    elsif params[:event][:select_post] == 'my_post' && params[:member_post_id].present?
      @selected_post = current_member.posts.find(params[:member_post_id])
      @event.post_id = @selected_post.id
    elsif params[:event][:select_post] == 'favorite_post' && params[:favorite_post_id].present?
      @selected_post = Post.find(params[:favorite_post_id])
      @event.post_id = @selected_post.id
    end
    @event.member_id = current_member.id
  end
end
