require File.expand_path('../../test_helper', __FILE__)

class ScmmProjectConfigurationControllerTest < Redmine::ControllerTest

  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :scmm_project_configurations

  def setup
    @request.headers['HTTP_ACCEPT'] = "application/json"
  end

  def test_update
    @request.session[:user_id] = 2
    Project.find(1).enabled_module_names = [:scm_manager]
    Role.find(1).add_permission! :scmm_configure_project
    patch(
      :update,
      :params => {
        :id => 1,
        :project_id => "ecookbook",
        :scmm_project_configuration => {
          :scm_url => "https://localhost/scm/repo/test/repository",
          :bug_tracker => "Bug"
        }
      }
    )
    assert_response :success

    written_configuration = ScmmProjectConfiguration.find(1)
    assert_equal "https://localhost/scm/repo/test/repository", written_configuration[:scm_url]
    assert_equal "Bug", written_configuration[:bug_tracker]
  end

  def test_update_with_cleanup
    @request.session[:user_id] = 2
    Project.find(1).enabled_module_names = [:scm_manager]
    Role.find(1).add_permission! :scmm_configure_project
    patch(
      :update,
      :params => {
        :id => 1,
        :project_id => "ecookbook",
        :scmm_project_configuration => {
          :scm_url => "https://localhost/scm/repo/test/repository//",
          :bug_tracker => " Bug  "
        }
      }
    )
    assert_response :success

    written_configuration = ScmmProjectConfiguration.find(1)
    assert_equal "https://localhost/scm/repo/test/repository", written_configuration[:scm_url]
    assert_equal "Bug", written_configuration[:bug_tracker]
  end

  def test_update_without_authentication
    patch(
      :update,
      :params => {
        :id => 1,
        :project_id => "ecookbook",
        :scmm_project_configuration => {
          :scm_url => "https://localhost/scm/repo/test/repository",
          :bug_tracker => "Bug"
        }
      }
    )
    assert_response :forbidden
  end

  def test_update_without_permission
    @request.session[:user_id] = 2
    Project.find(1).enabled_module_names = [:scm_manager]
    patch(
      :update,
      :params => {
        :id => 1,
        :project_id => "ecookbook",
        :scmm_project_configuration => {
          :scm_url => "https://localhost/scm/repo/test/repository",
          :bug_tracker => "Bug"
        }
      }
    )
    assert_response :forbidden
  end

  def test_update_without_active_module
    @request.session[:user_id] = 2
    Role.find(1).add_permission! :scmm_configure_project
    patch(
      :update,
      :params => {
        :id => 1,
        :project_id => "ecookbook",
        :scmm_project_configuration => {
          :scm_url => "https://localhost/scm/repo/test/repository",
          :bug_tracker => "Bug"
        }
      }
    )
    assert_response :forbidden
  end
end
