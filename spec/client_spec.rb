require "spec_helper"

describe DiasporaApi::Client do
  def client
    @client ||= DiasporaApi::Client.new(test_pod_host)
  end

  before do
    client.log_level = Logger::DEBUG
  end

  describe "nodeinfo" do
    it "returns href for the nodeinfo document" do
      expect(client.nodeinfo_href).not_to be_nil
    end

    it "returns nil for the wrong pod URI" do
      expect(DiasporaApi::Client.new("http://example.com").nodeinfo_href).to be_nil
    end

    it "returns nil for the non-existent URI" do
      expect(DiasporaApi::Client.new("http://example#{r_str}.local").nodeinfo_href).to be_nil
    end
  end

  describe "#registration" do
    it "returns 302 on correct query" do
      expect(client.register("test#{r_str}@test.local", "test#{r_str}", "123456")).to be_truthy
    end
  end

  context "require registration" do
    before do
      @username = "test#{r_str}"
      expect(client.register("test#{r_str}@test.local", @username, "123456")).to be_truthy
    end

    describe "#retrieve_remote_person" do
      it "returns 200" do
        expect(client.retrieve_remote_person("hq@pod.diaspora.software").response.code).to eq("200")
      end
    end

    describe "#find_or_fetch_person" do
      it "returns correct response" do
        people = client.find_or_fetch_person("hq@pod.diaspora.software")
        expect(people).not_to be_nil
        expect(people.count).to be > 0
      end
    end

    describe "#get_attributes" do
      it "returns aspect list" do
        expect(client.aspects.count).to be > 0
      end
    end

    describe "#sign_out" do
      it "returns 204 on correct sign out" do
        expect(client.sign_out.code).to eq("204")
      end
    end

    context "with second user" do
      before do
        @client = nil
        @username2 = "test#{r_str}"
        expect(client.register("test#{r_str}@test.local", @username2, "123456")).to be_truthy
      end

      it "adds the other user to an aspect" do
        people = client.search_people(@username)
        expect(people.count).to be > 0
        result = client.add_to_aspect(people.first["id"], client.aspects.first["id"])
        expect(result).to be_truthy
      end
    end
  end
end