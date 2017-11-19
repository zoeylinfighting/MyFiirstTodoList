#備註事項：
class TodosController < ApplicationController
  before_action :set_todo, :only => [:show, :edit, :update, :destroy]

  def index
    @todos = Todo.order(due_date: :asc)
    #依到期日（due_date）近到遠，取得todos
  end

  def new
    @todo = Todo.new
  end

  def create
    #依傳入參數new一個Todo實例
    @todo = Todo.new(todo_params)
    #如果驗證成功，則儲存並回到列表頁，告知成功新增
    #如果驗證失敗，則不儲存，並保留已填入資訊，回到new，繼續填寫
    if @todo.save
      #跳出通知訊息，告知成功新增
      flash[:notice] = 'Todo-list was successfully added!'
      #重新發出request，導往列表頁。對瀏覽器來說會重整頁面
      redirect_to todos_url
    else
      #當驗證失敗時，將@todo傳入new.html.erb做render
      #以達成體驗上：「保留已填寫資料，讓使用者可以繼續填寫錯誤的部分」
      render :action => :new
    end
  end

  #彷彿沒有內容，是因為原先次action內的代碼：
  # def show
  #   @todo = Todo.find(params[:id])
  # end
  #此段的作用已被 before_action :find_todo 取代 

  def update
    # @todo = Todo.find(params[:id])
    #此行的作用已被 before_action :find_todo 取代

    #如果驗證成功，則更新，並回到列表頁，告知成功更新
    #如果驗證失敗，則不更新，並保留已填寫的資料，回到edit,繼續填寫
    if @todo.update_attributes(todo_params)
      #經過find id之後，再透過update_attributes,將更改過的資料回送至資料庫
      #跳出通知訊息，告知成功更新
      flash[:notice] = 'Todo-list was successfully updated!'
      #重新發出request,導往列表頁。對瀏覽器來說會重整頁面
      redirect_to todo_url(@todo)
    else
      #當驗證失敗時，將@todo傳入edit.html.erb做render
      #以達成體驗上：「保留已填寫資料，讓使用者可以繼續填寫錯誤的部分」
      reder :action => :edit
    end
  end

  def destroy
    # @todo = Todo.find(params[:id])
    # 此行的作用已被before_action :find_todo 取代

    # Todo#can_destroy?定義在todo.rb裡
    # 如果可以刪除，則刪除，並回到列表頁，告知刪除成功
    # 如果不允許刪除，則回到列表頁，並告知過期
    if @todo.can_destroy?
      @todo.destroy
      # 跳出警告訊息，告知成功刪除
      flash[:notice] = 'Task was successfully deleted!!'
      # 重新發出request，導往列表頁。對瀏覽器來說會重整頁面
      redirect_to todos_url
    else
      # 跳出警告訊息，告知過期
      flash[:alert] = 'Task is overdue, can not be deleted! Try to finish it! You can make it!!'
      # 重新發出request，導往列表頁。對瀏覽器來說會重整頁面
      redirect_to todos_url
    end
  end

  private

  # 在#edit, #update, #destroy都有找到特定 ID todo的需求
  # 於是可以提取出 before_action :find_todo
  # 在以上三個action執行之前，先找出特定 ID 的 todo
  # 方法命名慣用（find_todo)，但是可自行決定，所以用（set_todo）

  def set_todo
    @todo = Todo.find(params[:id])
  end

  # Term: strong parameters, > Rails 4 only.
  # 基於安全性考量，不可以直接將未經允許 (permit) 的參數導入 model做新增或修改
  # 可視需求在各 controller 分開獨立指定允許的內容
  # 方法命名（todo_params)只是慣用，實際上可自行決定

  def todo_params
    # params 變數是Rails在消化完 http request 後，所留下的 controller 常用參數群
    # #require 方法裡的 symbol 與 form 送回的物件名稱相同
    # #permit 方法裡的 symbol 與 form 送回的物件欄位名稱相同
    params.require(:todo).permit(:title, :due_date, :description)
  end

end