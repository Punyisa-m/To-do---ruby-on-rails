class TodosController < ApplicationController
  before_action :set_todo, only: %i[show edit update destroy change_status]

def change_status
  @todo.update(status: todo_params[:status])
  respond_to do |format|
    format.turbo_stream { render turbo_stream: turbo_stream.remove("#{helpers.dom_id(@todo)}_container") }
    format.html { redirect_to todos_path, notice: "Updated todo status." }
  end
end

  # GET /todos or /todos.json
  def index
    if params[:status] == "complete"
      @todos = Todo.where(status: "complete")
    else
      @todos = Todo.where(status: "incomplete")
    end
  end



  # GET /todos/1 or /todos/1.json
  def show
    
  end

  # GET /todos/new
  def new
    @todo = Todo.new
    @category = Category.find(params[:category_id]) if params[:category_id]
  end

  # GET /todos/1/edit
  def edit
  end

  # POST /todos or /todos.json
  def create
    @category = Category.find(params[:todo][:category_id])
    @todo = @category.todos.new(todo_params)
    @todo.status = "incomplete"

    respond_to do |format|
      if @todo.save
        format.turbo_stream
        format.html { redirect_to todo_url(@todo), notice: "Todo was successfully created." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("#{helpers.dom_id(@todo)}_form", partial: "form", locals: { todo: @todo }) }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @todo.update(todo_params)
        format.turbo_stream
        format.html { redirect_to todo_url(@todo), notice: "Todo was successfully updated." }
        format.json { render :show, status: :ok, location: @todo }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("#{helpers.dom_id(@todo)}_form", partial: "form", locals: { todo: @todo }) }
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @todo.errors, status: :unprocessable_entity }
      end
    end
  end
  # DELETE /todos/1 or /todos/1.json
  def destroy
    @todo.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("#{helpers.dom_id(@todo)}_container") }
      format.html { redirect_to todos_url, notice: "Todo was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_todo
      @todo = Todo.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def todo_params
      params.require(:todo).permit(:name, :status, :category_id)
    end
end
