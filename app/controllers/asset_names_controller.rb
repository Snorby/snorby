class AssetNamesController < ApplicationController
  respond_to :html, :xml, :json, :js, :csv

  before_filter :require_administrative_privileges
  helper_method :sort_column, :sort_direction


  def get_bulk_upload
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def bulk_upload
    errors = []
    line_number = 0
    overwrite = params.fetch(:overwrite, false)

    if params[:csv]

      text = params[:csv].read
      text.lines.each do |line|

        line_number += 1
        line = line.strip
        next unless line && line.length > 0

        items = line.split(",")

        unless items.length >= 2
          errors.push(line_number, "Incorrect format: #{line}")
          next
        end

        ip_address = (items[0] || "").strip
        name = (items[1] || "").strip
        global = true
        sensor_name = nil
        
        unless ip_address && name
          errors.push(line_number, "Incorrect format (IP and name required): #{line}")
          next
        end

        if items.length > 2
          sensor_name = items[2].strip 
          global = false if sensor_name.length > 0
        end

        begin
          ip = IPAddr.new(ip_address,Socket::AF_INET)
        rescue => e
          errors.push(line_number, "Invalid IP: #{ip_address}")
          next
        end

        if global 

          # if there's already a global name for ip_address
          existing_name = AssetName.first(:ip_address => ip, :global => true)

          if existing_name
            if overwrite
              existing_name.name = name
              existing_name.save!
            else
              errors.push(line_number, "#{ip.to_s} already has a global definition")
            end
          else
            asset_name = AssetName.create(:ip_address => ip, :name => name, :global => true)
            if !asset_name.save!
              errors.push(line_number, "Error saving: #{items}, #{asset_name.errors.join(",")}")
            end

          end
        else

          sensor = Sensor.first(:hostname => sensor_name) || Sensor.first(:name => sensor_name)

          unless sensor
            errors.push(line_number, "#{sensor_name} has no matching sensor")
            next
          end

          # look for a sensor match
          sql = %{
           select id, name, ip_address, global
           from asset_names a
           inner join agent_asset_names b on b.asset_name_id = a.id
           where global = 0 and ip_address = ? and sensor_sid = ?
          }

          matched_assets = AssetName.find_by_sql([sql, ip.to_i, sensor.sid])

          if matched_assets && matched_assets.length > 0 && !overwrite
            errors.push(line_number, "#{ip.to_s} #{sensor.hostname} already has a definition")
            next
          end

          if matched_assets
            AgentAssetName.delete_agent_references(ip.to_i, sensor.sid)
          end

          # look for a non-global entry with that name.
          asset_name = AssetName.find_or_create(
           { :ip_address => ip, :global => false, :name => name },
           { :ip_address => ip, :global => false, :name => name })

          asset_name.sensors.push(sensor)

          asset_name.save!
          if !asset_name.save!
              errors.push(line_number, "Error saving: #{items}, #{asset_name.errors.join(",")}")
          end

        end
      end
    end

    if errors.length > 0
      logger.error "Errors uploading file: #{errors}"
    end

    respond_to do |format|
      if errors.length == 0
        format.html { redirect_to asset_names_path, notice: 'File Successfully Uploaded' }
        format.js
        format.json {render :json => {
          :status => 'success'
        }}
      else
        format.json { render :json => { :status => 'error',
                                        :errors => errors } }
        format.html { redirect_to asset_names_path, notice: 'There was an error uploading the file' }
      end
    end
  end

  def add
    update
  end

  def update

    params[:ip_address] = IPAddr.new(params[:ip_address],Socket::AF_INET) if params[:ip_address]

    @asset_name = if params[:id]
       AssetName.find_or_create({ :id => params[:id] },
            { :ip_address => params[:ip_address],
              :name => params[:name],
              :global => params[:global]
            })
    else
      AssetName.find_or_create({
        :ip_address => params[:ip_address],
        :name => params[:name],
        :global => params[:global]
      },
      { :ip_address => params[:ip_address],
        :name => params[:name],
        :global => params[:global]
      })
    end

    @asset_name.attributes = { :global => params[:global], :name => params[:name] }
   
    sensors = [] 
    if params[:global] && params[:global].to_i == 1
      
      if params[:id]
        AgentAssetName.all(:asset_name_id => params[:id]).destroy!
      end

      @asset_name.sensors = []
    else
      if params[:sensors] && params[:sensors].try(:to_a)
        sensors = Sensor.all(:sid => params[:sensors]).to_a || []
      end      
    end

    respond_to do |format|
      if @asset_name.save_with_sensors(sensors)
        format.html {render :layout => true}
        format.js
        format.json {render :json => {
          :asset_name => @asset_name.detailed_json,
        }}
      else
        format.json { render :json => { :errors => @asset_name.errors } }
      end
    end

  end

  def lookup
    ip = IPAddr.new(params[:ip_address].to_i,Socket::AF_INET)
    @asset_names = AssetName.all(:ip_address => ip)

    respond_to do |format|
      format.html {render :layout => true}
      format.js
      format.json {render :json => {
        :assets => @asset_names
      }}
    end
  end

  def remove
    @asset_name = AssetName.find_by_id(params[:id])
    AgentAssetName.all(:asset_name_id => params[:id]).destroy!
    @asset_name.destroy! if @asset_name
    render :layout => false, :json => @asset_name
  end

  def index
    params[:sort] = sort_column
    params[:direction] = sort_direction
    @asset_names = AssetName.sorty(params)
  end

  private

  def sort_column
    if params.has_key?(:sort)
      return params[:sort].to_sym if Event::SORT.has_key?(params[:sort].to_sym) or [:signature].include?(params[:sort].to_sym)
    end

    :ip_address
  end

  def sort_direction
    %w[asc desc].include?(params[:direction].to_s) ? params[:direction].to_sym : :desc
  end

end
