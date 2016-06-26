class QueryController < ApplicationController
  def create
    # p params.inspect
    start_year = params[:date].to_i - params[:year_range].to_i
    end_year = params[:date].to_i + params[:year_range].to_i
    radius = params[:radius].to_i
    lat = params[:lat]
    long = params[:long]
    url = "https://wdq.wmflabs.org/api?q=CLAIM[31:178561]%20and%20between[582,#{start_year},#{end_year}]%20and%20around[625,#{lat},#{long},#{radius}]"
    response = HTTParty.get(url)
    qIDS = response['items'].map{|id| 'Q'+id.to_s}
    qIDString = qIDS.join("%7C")

    mediaUrl = "https://www.wikidata.org/w/api.php?action=wbgetentities&format=json&ids=#{qIDString}&props=labels%7Cdescriptions%7Cclaims%7Csitelinks%2Furls&languages=en&languagefallback=1&sitefilter=&formatversion=2"
    media_response = HTTParty.get(mediaUrl)
    # p first_battle_title = media_response['entities']["Q#{qIDS[0]}"]['labels']['en']['value']

    parsed_response = media_response['entities'].map do |entity, value|
            # binding.pry
        {entity => {
            title: value['labels']['en']['value'],
            # description: value['descriptions']['en']['value'],
            latitude: value['claims']['P625'][0]['mainsnak']['datavalue']['value']['latitude'],
            longitude: value['claims']['P625'][0]['mainsnak']['datavalue']['value']['longitude'],
            end_time: value['claims']['P582'][0]['mainsnak']['datavalue']['value']['time'],
            link: value['sitelinks']['enwiki']['url']
        }}
    end
    parsed_response.unshift({'qids' => qIDS})
    render json: parsed_response

    end
end