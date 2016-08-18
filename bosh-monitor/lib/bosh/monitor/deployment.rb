module Bosh::Monitor
  class Deployment

    ATTRIBUTES = [:name]
    ATTRIBUTES.each do |attribute|
      attr_reader attribute
    end

    def initialize(instance_data)
      @logger = Bhm.logger
      @name     = instance_data['name']
      @instance_id_to_instance = {}
    end

    def self.create(deployment_data)
      unless deployment_data.kind_of?(Hash)
        Bhm.logger.error("Invalid format for Deployment data: expected Hash, got #{deployment_data.class}: #{deployment_data}")
        return nil
      end

      unless deployment_data['name']
        Bhm.logger.error("Deployment data has no name: got #{deployment_data}")
        return nil
      end

      Deployment.new(deployment_data)
    end


    def add_instance(instance_data)
      instance = Bhm::Instance.create(instance_data)

      unless instance
        return false
      end

      unless instance.expects_vm
        @logger.debug("Instance with no VM expected found: #{instance.id}")
        return false
      end

      instance.deployment = name
      if @instance_id_to_instance[instance.id].nil?
        @logger.debug("Discovered instance #{instance_data['id']}")
        @instance_id_to_instance[instance.id] = instance
      end
      true
    end

    def add_instances(instances_data)
      instances_data.each do |instance_data|
        add_instance(instance_data)
      end
    end

    def remove_instance(instance_id)
      @instance_id_to_instance.delete(instance_id)
    end

    def instance(instance_id)
      @instance_id_to_instance[instance_id]
    end

    def instances
      @instance_id_to_instance.values
    end

    def instance_ids
      @instance_id_to_instance.keys.to_set
    end
  end
end
