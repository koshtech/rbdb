class ApplicationController < ActionController::Base
  protect_from_forgery

  include SessionSizedList

  before_filter :authenticate
  before_filter :establish_connection
  before_filter :fill_last_queries
  before_filter :fill_last_tables
  before_filter :fill_system_stats

  protected
  def authenticate
    return true if logged_in?
    session[:return_to] = request.url
    flash[:error] = 'Please give your credentials'
    redirect_to login_path
  end

  def establish_connection
    ActiveRecord::Base.establish_connection :username => session[:username],
      :password => session[:password],
      :adapter => 'mysql2',
      :database => '',
      :host => session[:host],
      :port => session[:port]
    return true
  end

  def select_db
    if params[:database_id].blank?
      flash[:notice] = 'You must select a database!'
      redirect_to :controller => '/databs', :action => :index
      return false
    end
    @datab = Datab.find(params[:database_id])
    Datab.execute "use #{@datab.name}"
  end

  def select_table
    @table = @datab.tables.find((params[:table_id] or params[:id]))
    return true if !@table.nil?
    flash[:notice] = "The table #{params[:table_id] or params[:id]} does not exist"
    redirect_to :controller => '/databs', :action => :index
    return false
  end

  def fill_last_queries
    @sqls = []
    session[:sqls].each do |s|
      @sqls << Sql.new(s)
    end if session[:sqls]
    return true
  end

  MAX_STORED_QUERIES = 5
  def store_sql(sql, datab)
    add_to_session :sqls, {
      :body => sql.body,
      :id => sql.id,
      :num_rows => sql.num_rows,
      :db => datab.name
    }, MAX_STORED_QUERIES
  end

  def fill_last_tables
    @last_tables = session[:last_tables] or []
  end

  def fill_system_stats
    @load_average = IO.popen("uptime") { |pipe| pipe.read }.split(" ")[-3] rescue 0
    questions = 0
    uptime = 0
    ActiveRecord::Base.connection.execute("SHOW STATUS").each do |r|
      questions = r[1].to_i if r[0] == 'Questions'
      uptime = r[1].to_i if r[0] == 'Uptime'
    end
    @requests_per_second = questions.to_f / uptime rescue 0

    ActiveRecord::Base.connection.execute("SHOW VARIABLES").each do |r|
      @server_version = r[1] if r[0] == 'version'
    end
    @server = 'localhost' # FIXME
  end

  def logged_in?
    session[:username]
  end

end
