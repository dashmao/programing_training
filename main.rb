require 'sinatra'
require 'sqlite3'
require 'securerandom'
require 'fileutils'
# require 'sinatra/json'

db = SQLite3::Database.new "pixiv_clone.db"
db.results_as_hash = true

#トップページ
get '/star' do
  post_id = params["post_id"].to_i
  post = db.execute("SELECT star_count from posts where id = ?", post_id)

  new_star_count = post[0]["star_count"] + 1
  db.execute("UPDATE posts SET star_count = ? WHERE id = ?", new_star_count, post_id)
  return "スターを付けました"
end

get '/' do
  @posts = db.execute("select * from posts;")
  @post = @posts.last
  erb :index
end

post '/' do
  @name = @params[:ex_text]

  if params["file"][:type].include? "jpeg"
    ext = "jpg"
  elsif params["file"][:type].include? "png"
    ext = "png"
  end

  file_name = SecureRandom.hex + "." + ext

  FileUtils.mv(params["file"][:tempfile], "./public/uploads/" + file_name)

  @image = @params[:file_name]

  stmt = db.prepare ("insert into posts
  (text, img_file_name)
  values
  (?,?);
  ")
  stmt.bind_params(@name, file_name)
  stmt.execute

  @posts = db.execute("select * from posts;")
  erb :index
end
  #トップページを表示する前にする処理

  # posts = db.execute("select * from posts;")
  # erb :index, { :locals => { :posts => posts }}
