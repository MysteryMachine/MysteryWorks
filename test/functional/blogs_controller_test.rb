require 'test_helper'

class BlogsControllerTest < ActionController::TestCase
  setup do
    @blog = blogs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:blogs)
  end

  test "should create blog" do
    assert_difference('Blog.count') do
      post :create, blog: { name: @blog.name }
    end

    assert_response 201
  end

  test "should show blog" do
    get :show, id: @blog
    assert_response :success
  end

  test "should update blog" do
    put :update, id: @blog, blog: { name: @blog.name }
    assert_response 204
  end

  test "should destroy blog" do
    assert_difference('Blog.count', -1) do
      delete :destroy, id: @blog
    end

    assert_response 204
  end
end
