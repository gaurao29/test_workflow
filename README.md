*Modified Add readme for workflow to get diff of only added contents*
Added

newly added lines

get '/meta/charts' do
        result = get_charts(params['tag'], params['name'])
        GoshPosh::Json.generate(result)
end


get '/meta/charts/:chart_id/edition' do
        chart_id = params[:chart_id] unless params[:chart_id].nil? || params[:chart_id].empty?
        raise Pm::Service::Errors::NotFoundError unless chart_id

        result = get_most_recent_chart_edition_by_id(chart_id)
        GoshPosh::Json.generate(result)
end

get '/meta/charts/:chart_id2/edition3' do
        chart_id = params[:chart_id] unless params[:chart_id].nil? || params[:chart_id].empty?
        raise Pm::Service::Errors::NotFoundError unless chart_id

        result = get_most_recent_chart_edition_by_id(chart_id)
        GoshPosh::Json.generate(result)
end