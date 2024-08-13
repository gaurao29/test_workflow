require 'set'

def sanitize_route(route_with_verb)
  route_with_verb = route_with_verb&.gsub(/'/, '')
  route_with_verb = route_with_verb&.gsub(/"/, '')
  route_with_verb = route_with_verb&.gsub(/ do/, '|')
  route_with_verb = route_with_verb&.strip
  return route_with_verb if route_with_verb&.length&.positive?

  nil
end

def find_sinatra_routes_v1(diff_file_path, url_prefix)
  # Define the HTTP verbs that correspond to Sinatra routes
  http_verbs = %w[get post put delete patch]
  routes = Set.new
  puts "Reading file: #{diff_file_path}"
  # get /meta/charts do get /meta/charts/:chart_id/edition do
  # get /meta/charts | get /meta/charts/:chart_id/edition |
  # Read the file line by line and check for HTTP verbs
  File.readlines(diff_file_path).each_with_index do |line, _index|
    line = sanitize_route(line.strip)
    split_routes = line.split('|')
    puts "Split routes: #{split_routes}"
    split_routes.each do |verb_and_path|
      # Check if the line starts with an HTTP verb followed by a space or '('
      next unless http_verbs.any? { |verb| line.strip.start_with?("#{verb} ", "#{verb}(") }
      route_with_verb = sanitize_route(verb_and_path.strip)
      route_verb_split = route_with_verb.split
      verb = route_verb_split[0] if route_with_verb && route_verb_split.length.positive?
      route = route_verb_split[1] if route_with_verb && route_verb_split.length > 1
      routes << "#{verb} #{url_prefix}#{route}" if route[0] == '/'
    end
  end

  routes
end


def find_sinatra_routes_v2(diff_file_paths, app_file_url_prefix_map)
  # Define the HTTP verbs that correspond to Sinatra routes
  http_verbs = %w[get post put delete patch]
  routes = Set.new
  # get /meta/charts do get /meta/charts/:chart_id/edition do
  # get /meta/charts | get /meta/charts/:chart_id/edition |
  # Read the file line by line and check for HTTP verbs
  diff_file_paths.each do |diff_file|
    puts "Chnaged File: #{file}"
    url_prefix = app_file_url_prefix_map.get(diff_file)
    File.readlines(diff_file).each_with_index do |line, _index|
      line = sanitize_route(line.strip)
      split_routes = line.split('|')
      split_routes.each do |verb_and_path|
        # Check if the line starts with an HTTP verb followed by a space or '('
        next unless http_verbs.any? { |verb| line.strip.start_with?("#{verb} ", "#{verb}(") }
        route_with_verb = sanitize_route(verb_and_path.strip)
        route_verb_split = route_with_verb.split
        verb = route_verb_split[0] if route_with_verb && route_verb_split.length.positive?
        route = route_verb_split[1] if route_with_verb && route_verb_split.length > 1
        routes << "#{verb} #{url_prefix}#{route}" if route[0] == '/'
      end
    end
  end
  routes
end

map = {'README.md' => '/readme', 'CHANGELOG.md' => '/changelog'}
all_routes = find_sinatra_routes_v2(Dir[ENV['DIFF_FILE_PATH']],map)
puts "All routes:"
all_routes.each do |route|
  puts route
end
