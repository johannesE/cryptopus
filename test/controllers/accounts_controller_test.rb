# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class AccountsControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper

  test 'move account from one group to another' do
    login_as (:bob)

    account1 = accounts(:account1)
    group1 = groups(:group1)
    team1 = teams(:team1)
    group2 = team1.groups.new(id: 12, name: 'Test', description: 'group_description')
    group2.save

    patch :update, id: account1, group_id: group1, team_id: team1, account: {group_id: group2}
    account1.reload

    assert_equal account1.group_id, group2.id
  end

  test 'show breadcrumb path 1 if user is on index of accounts' do
    login_as (:bob)

    group1 = groups(:group1)
    team1 = teams(:team1)

    get :index, group_id: group1, team_id: team1
    assert_select '.breadcrumb', text: 'Teamsteam1group1'
    assert_select '.breadcrumb a', count: 2
    assert_select '.breadcrumb a', text: 'Teams'
    assert_select '.breadcrumb a', text: 'team1'
    assert_select '.breadcrumb a', text: 'group1', count: 0
  end

  test 'show breadcrump path 2 if user is on edit of accounts' do
    login_as (:bob)

    group1 = groups(:group1)
    team1 = teams(:team1)
    account1 = accounts(:account1)

    get :edit, id: account1, group_id: group1, team_id: team1
    assert_select '.breadcrumb', text: 'Teamsteam1group1account1'
    assert_select '.breadcrumb a', count: 3
    assert_select '.breadcrumb a', text: 'Teams'
    assert_select '.breadcrumb a', text: 'team1'
    assert_select '.breadcrumb a', text: 'group1'
    assert_select '.breadcrumb a', text: 'account1', count: 0
  end

  test 'Error message if you attempt to look into a team youre not member of' do
    team2 = teams(:team2)
    group2 = groups(:group2)

    login_as(:alice)

    get :index, team_id: team2, group_id: group2

    assert_match /You are not member of this team/ , flash[:error]
    assert_redirected_to teams_path
  end

end
