require_relative './base_test'
Dir[File.join(File.dirname(__FILE__), '../../src/yoneoka/*.rb')].each {|file| require file}

module Yoneoka
  class ObserveApiTest
    # calc_distance(lat1, lng1, lat2, lng2)

    # 編集（位置情報有り）
    json_data = {
        lat: 34.663601,
        long: 135.496921,
        radius: 50,
    }

    # 監視(範囲に入っていないとき)
    json_data_in = {
        lat: 34.663509,
        long: 135.497475 # 約51m の距離
    }

    # 監視(範囲に入ったとき)
    json_data_out = {
        lat: 34.663509,
        long: 135.497445 # 約49m の距離
    }

    json_data2 = {
        lat: -15.791726,
        long: -47.889573,
    }


    json_data_in2 = {
        lat: -15.792481,
        long: -47.889934 # 約92m の距離
    }
    # 監視(範囲から出たとき)
    json_data_out2 = {
        lat: -15.792591,
        long: -47.889934 # 約103m の距離
    }

    puts "--- in  ---"
    puts ObserveApi.new.calc_distance(json_data[:lat], json_data[:long], json_data_in[:lat], json_data_in[:long])
    puts "--- out ---"
    puts ObserveApi.new.calc_distance(json_data[:lat], json_data[:long], json_data_out[:lat], json_data_out[:long])
    puts "--- in2  ---"
    puts ObserveApi.new.calc_distance(json_data2[:lat], json_data2[:long], json_data_in2[:lat], json_data_in2[:long])
    puts "--- out2 ---"
    puts ObserveApi.new.calc_distance(json_data2[:lat], json_data2[:long], json_data_out2[:lat], json_data_out2[:long])

  end
end

