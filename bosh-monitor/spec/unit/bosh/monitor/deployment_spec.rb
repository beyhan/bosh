require 'spec_helper'

describe Bhm::Deployment do

  describe '.create' do
    context 'from valid hash' do
      let(:deployment_data) { {'name' => 'deployment_name'} }

      it 'creates a deployment' do
        deployment = Bhm::Deployment.create(deployment_data)

        expect(deployment).to be_a(Bhm::Deployment)
      end
    end

    context 'from invalid hash' do
      let(:deployment_data) { {} }

      it 'fails to create a deployment' do
        deployment = Bhm::Deployment.create(deployment_data)

        expect(deployment).to be_nil
      end
    end

    context 'from invalid data' do
      let(:deployment_data) { 'no-hash' }

      it 'fails to create deployment' do
        deployment = Bhm::Deployment.create(deployment_data)

        expect(deployment).to be_nil
      end
    end
  end

  describe '#add_instance' do
    let(:deployment) { Bhm::Deployment.create({'name' => 'deployment-name'}) }

    it "add instance with well formed director instance data" do
      expect(deployment.add_instance({'id' => 'iuuid', 'job' => 'zb', 'index' => '0', 'expects_vm' => true})).to be(true)
      expect(deployment.instance('iuuid')).to be_a(Bhm::Instance)
      expect(deployment.instance('iuuid').id).to eq('iuuid')
      expect(deployment.instance('iuuid').deployment).to eq('deployment-name')
    end

    it "add only new instances" do
      deployment.add_instance({'id' => 'iuuid', 'job' => 'zb', 'index' => '0', 'expects_vm' => true})
      deployment.add_instance({'id' => 'iuuid', 'job' => 'zb', 'index' => '0', 'expects_vm' => true})

      expect(deployment.instances.size).to eq(1)
    end

    it "refuse to add instance with 'expects_vm=false'" do
      expect(deployment.add_instance({'id' => 'iuuid', 'job' => 'zb', 'index' => '0', 'expects_vm' => false})).to be(false)
    end
  end

  describe '#add_instances' do
    let(:deployment) { Bhm::Deployment.create({'name' => 'deployment-name'}) }

    it 'adds multiple instances' do
      instance_1 = {'id' => 'iuuid1', 'job' => 'zb1', 'index' => '1', 'expects_vm' => true}
      instance_2 = {'id' => 'iuuid2', 'job' => 'zb2', 'index' => '2', 'expects_vm' => true}

      deployment.add_instances([instance_1, instance_2])

      expect(deployment.instances.size).to eq(2)
      expect(deployment.instance('iuuid1')).to be_a(Bhm::Instance)
      expect(deployment.instance('iuuid2')).to be_a(Bhm::Instance)
    end

    it "adds only unique instances" do
      instance_1 = {'id' => 'iuuid', 'job' => 'zb', 'index' => '1', 'expects_vm' => true}
      instance_2 = {'id' => 'iuuid', 'job' => 'zb', 'index' => '2', 'expects_vm' => true}

      deployment.add_instances([instance_1, instance_2])

      expect(deployment.instances.size).to eq(1)
      expect(deployment.instance('iuuid')).to be_a(Bhm::Instance)
    end

    it "refuse to add instance with 'expects_vm=false'" do
      instance_1 = {'id' => 'iuuid1', 'job' => 'zb1', 'index' => '1', 'expects_vm' => true}
      instance_2 = {'id' => 'iuuid2', 'job' => 'zb2', 'index' => '2', 'expects_vm' => false}

      deployment.add_instances([instance_1, instance_2])

      expect(deployment.instances.size).to eq(1)
      expect(deployment.instance('iuuid1')).to be_a(Bhm::Instance)
    end
  end

  describe '#instance_ids' do
    let(:deployment) { Bhm::Deployment.create({'name' => 'deployment-name'}) }

    it "returns all instance ids" do
      deployment.add_instance({'id' => 'iuuid1', 'job' => 'zb', 'index' => '0', 'expects_vm' => true})
      deployment.add_instance({'id' => 'iuuid2', 'job' => 'zb', 'index' => '0', 'expects_vm' => true})

      expect(deployment.instance_ids).to eq(['iuuid1', 'iuuid2'].to_set)
    end

    it "removes ids from removed instances" do
      deployment.add_instance({'id' => 'iuuid1', 'job' => 'zb', 'index' => '0', 'expects_vm' => true})
      deployment.add_instance({'id' => 'iuuid2', 'job' => 'zb', 'index' => '0', 'expects_vm' => true})

      expect(deployment.instance_ids).to eq(['iuuid1', 'iuuid2'].to_set)

      deployment.remove_instance('iuuid1')
      expect(deployment.instance_ids).to eq(['iuuid2'].to_set)
    end
  end

  describe '#remove_instance' do
    let(:deployment) { Bhm::Deployment.create({'name' => 'deployment-name'}) }

    it "remove instance with id" do
      deployment.add_instance({'id' => 'iuuid', 'job' => 'zb', 'index' => '0', 'expects_vm' => true})

      expect(deployment.instance('iuuid')).to be_a(Bhm::Instance)
      expect(deployment.remove_instance('iuuid').id).to be_truthy
      expect(deployment.instance('iuuid')).to be_nil
    end
  end
end
