#:nodoc:
class Admin::GroupsController < ApplicationController
  def index
    @groups = Group.all.order(:category, :name)
    @group = Group.new
  end

  def show
    @groups = Group.all.order(:category, :name)
    @group = Group.find_by_id params[:id]
  end

  def create
    @group = Group.new group_params

    if @group.save
      # manual impressionist call, otherwise the group has no id yet
      impressionist @group
      redirect_to @group
    else
      @groups = Group.all.order(:category, :name)
      render 'show'
    end
  end

  def update
    @group = Group.find_by_id params[:id]

    if @group.update(group_params)
      impressionist @group
      redirect_to @group
    else
      @groups = Group.all.order(:category, :name)
      render 'show'
    end
  end

  def destroy
    @group = Group.find(params[:id])

    if @group.category != "board"
      @group.destroy
      impressionist @group
      redirect_to groups_path
    else
      redirect_to group_path
    end
  end

  private

  def group_params
    params.require(:group).permit(:name, :category, :comments)
  end
end
