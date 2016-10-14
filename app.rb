require 'bundler'
Bundler.require

class Todo < ActiveRecord::Base
  belongs_to :user
end

class User < ActiveRecord::Base
  has_many :todos
end

class App < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :json_encoder, :to_json

  get("/") do
    "Hello World"
  end

  post("/users") do
    user = User.create(json_body)
    json user
  end

  get("/users/:id") do
    user = User.find(params[:id])
    json user
  end

  post("/users/:id/todos") do
    user = User.find(params[:id])
    if user.todos.count >= 100
      status 400
    else
      todo_params = {user: user}.merge(json_body)
      todo = Todo.create(todo_params)

      json todo
    end
  end

  get("/users/:id/todos") do
    todos = Todo.where(user_id: params[:id])
    json todos
  end

  get("/users/:id/todos/:todo_id") do
    todo = Todo.find(params[:todo_id])
    json todo
  end

  put("/users/:id/todos/:todo_id") do
    todo = Todo.find(params[:todo_id])
    binding.pry
    todo.update_attributes(json_body)
    json todo
  end

  def json_body
    JSON.parse(request.body.read, symbolize_names: true)
  end
end

App.run!
