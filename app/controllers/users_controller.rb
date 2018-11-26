class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update]
  before_action :correct_user,   only: [:edit, :update]

  def show
    @user = User.find(params[:id])
  end

  def dashboard
    if (current_user)
      enrollment_fall_2018 = Enrollment.where(user_id: current_user.id, term_id: 4)
      enrollment_spring_2019 = Enrollment.where(user_id: current_user.id, term_id: 5)
      @courses_fall_2018 = []
      @courses_spring_2019 = []
      if enrollment_fall_2018.count != 0
        enrollment_fall_2018.each do |e|
          course = Course.find(e.course_id)
          @courses_fall_2018.push(course)
        end
      end
      if enrollment_spring_2019.count != 0
        enrollment_spring_2019.each do |e|
          course = Course.find(e.course_id)
          @courses_spring_2019.push(course)
        end
      end
    else
      redirect_to root_url
    end

    @credits = current_user.credits
    if @credits.nil?
      @credits = 0
      @credits_percent = 0
    else
      @credits_percent = (((@credits/128.0)*100).round)
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the BranPlan!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
    else
      render 'edit'
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation, :credits)
    end

    # Confirms a logged-in user.
    def logged_in_user
      unless current_user
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    # Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless @user == current_user
    end

end
