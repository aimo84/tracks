ActiveSupport::Notifications.subscribe('sql.active_record') do |name, started, finished, unique_id, payload|
	($queries||=[]) << payload unless payload[:name].in? %w(CACHE SCHEMA)
	($query_time||=[]) << (finished-started)*1000 unless payload[:name].in? %w(CACHE SCHEMA)
	($query_time_started||=[]) <<	started unless payload[:name].in? %w(CACHE SCHEMA)
	($query_time_finished||=[]) <<	finished unless payload[:name].in? %w(CACHE SCHEMA)
	#event = ActiveSupport::Notifications::Event.new(name, started, finished, unique_id, payload)
	#($query_time||=[]) << event.duration unless payload[:name].in? %w(CACHE SCHEMA)
end

ActiveSupport::Notifications.subscribe('render_template.action_view') do |name, started, finished, unique_id, payload|
	($render_template||=[]) << (finished-started)*1000
	($render_template_started||=[]) << started
	($render_template_finished||=[]) << finished
	#puts "render template: #{payload[:identifier]} -> #{(finished-started)*1000} ms"
end

ActiveSupport::Notifications.subscribe('render_partial.action_view') do |name, started, finished, unique_id, payload|
	($render_partial||=[]) << (finished-started)*1000
	($render_partial_started||=[]) << started
	($render_partial_finished||=[]) << finished
	#puts "render partial: #{payload[:identifier]} -> #{(finished-started)*1000} ms"
end


ActiveSupport::Notifications.subscribe /process_action.action_controller/ do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  controller = event.payload[:controller]
  action = event.payload[:action]
  format = event.payload[:format] || "all"
  format = "all" if format == "*/*"
  status = event.payload[:status]
  key = "#{controller}.#{action}.#{format}.#{ENV["INSTRUMENTATION_HOSTNAME"]}"
  ActiveSupport::Notifications.instrument :performance, :action => :timing, :measurement => "#{key}.total_duration", :value => event.duration
  ActiveSupport::Notifications.instrument :performance, :action => :timing, :measurement => "#{key}.db_time", :value => event.payload[:db_runtime]
  ActiveSupport::Notifications.instrument :performance, :action => :timing, :measurement => "#{key}.view_time", :value => event.payload[:view_runtime]
  ActiveSupport::Notifications.instrument :performance, :measurement => "#{key}.status.#{status}"
	render_partial_time = 0
	render_template_time = 0
	if $render_partial
		render_partial_time += $render_partial.sum
	end
	if $render_template
		render_template_time += $render_template.sum
	end
	query_in_view = 0
	if $query_time_started 
		for i in 0...$query_time_started.length
			@in_view = false
			if $render_template_started
				for j in 0...$render_template_started.length
					if $query_time_started[i]-$render_template_started[j] > 0 and $render_template_finished[j]-$query_time_finished[i] > 0
						@in_view = true
					end
				end
			end
			if $render_partial_started
				for j in 0...$render_partial_started.length
					if $query_time_started[i]-$render_partial_started[j] > 0 and $render_partial_finished[j]-$query_time_finished[i] > 0
						@in_view = true
					end
				end
			end
			if @in_view
				query_in_view += ($query_time_finished[i]-$query_time_started[i])
			end
		end
	end
	if $queries
		str = "#{controller}.#{action} total_duration=#{event.duration} db_time=#{event.payload[:db_runtime]} view_runtime=#{event.payload[:view_runtime]} query_len=#{$queries.length} query_time=#{$query_time.sum} query_in_view=#{query_in_view} render_partial_time=#{render_partial_time} render_template_time=#{render_template_time}"
	#str = "#{controller}.#{action} total_duration=#{event.duration} number_of_queries=#{$queries.length}"
		puts str
		i=0
		$queries.each do |q|
			puts "\tquery #{$query_time[i]} ms, SQL: #{q[:sql]}"
			i += 1
		end
	end
	#::Dump_count+= 1
	#if ::Dump_count % 1024 == 0
  $queries = []
	$render_partial = []
	$render_template = []
	$query_time = []
	$query_time_started = []
	$query_time_finished = []
	$render_template_started = []
	$render_template_finished = []
	$render_partial_started = []
	$render_partial_finished = []
end
