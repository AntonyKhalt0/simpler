class TestsController < Simpler::Controller

  def index
    status 201
  end

  def create

  end

  def show
    @test = Test.find(id: params[:id])
  end

end
