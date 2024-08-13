Readme2
get '/meta/charts' do
        result = get_charts(params['tag'], params['name'])
        GoshPosh::Json.generate(result)
end