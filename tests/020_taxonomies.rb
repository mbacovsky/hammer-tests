"
na ose x
- admin
- org admin
- common user
na ose y
- jedna org
- dve org
na ose z
- default org set
- default org unset
na ose w
- resource z Foremana (domain?)
- resource z katella (product?)
"

IDX = '%05d' % sequence.next.to_s

@org_1 = {
    :name => "org_1_"+IDX
}

@org_2 = {
    :name => "org_2_"+IDX
}

@one_org = @org_1[:name]
@two_orgs = @org_1[:name] + ',' + @org_2[:name]

@one_org_admin_role = {
    :name => "Organization admin",
    :new_name => "One org admin #{IDX}",
    :organizations => @one_org
}

@two_orgs_admin_role = {
    :name => "Organization admin",
    :new_name => "Two orgs admin #{IDX}",
    :organizations => @two_orgs
}

@user_base = {
    :admin => false,
    :mail => "some.user@email.com",
    :password => "passwd",
    :auth_source_id => 1
}

#---- admin
@admin_no_org = @user_base.merge({
    :login => "admin_no_org_#{IDX}",
    :admin => true,
})

@admin_one_org_no_default = @user_base.merge({
    :login => "admin_one_org_no_default_#{IDX}",
    :admin => true,
    :organizations => @one_org,
})

@admin_one_org_default = @user_base.merge({
    :login => "admin_one_org_default_#{IDX}",
    :admin => true,
    :organizations => @one_org,
    :default_organization => @one_org
})

@admin_two_orgs_no_default = @user_base.merge({
    :login => "admin_two_orgs_no_default_#{IDX}",
    :admin => true,
    :organizations => @two_orgs,
})

@admin_two_orgs_default = @user_base.merge({
    :login => "admin_two_orgs_default_#{IDX}",
    :admin => true,
    :organizations => @two_orgs,
    :default_organization => @one_org
})


#---- org admin
@org_admin_one_org_no_default = @user_base.merge({
    :login => "org_admin_one_org_no_default_#{IDX}",
    :roles => @one_org_admin_role[:new_name],
    :organizations => @one_org,
})

@org_admin_one_org_default = @user_base.merge({
    :login => "org_admin_one_org_default_#{IDX}",
    :roles => @one_org_admin_role[:new_name],
    :organizations => @one_org,
    :default_organization => @one_org
})

@org_admin_two_orgs_no_default = @user_base.merge({
    :login => "org_admin_two_orgs_no_default_#{IDX}",
    :roles => @two_orgs_admin_role[:new_name],
    :organizations => @two_orgs,
})

@org_admin_two_orgs_default = @user_base.merge({
    :login => "org_admin_two_orgs_default_#{IDX}",
    :roles => @two_orgs_admin_role[:new_name],
    :organizations => @two_orgs,
    :default_organization => @one_org
})


@admin_attrs = {
    :admin => true
}

@domain = {
  :name => "domain #{IDX} #{rand(1000)}"
}

def test_domain_creation(user, domain, expected_organizations)
	as_user(user[:login], user[:password]) do
	  simple_test 'domain', 'create', domain

	  res = hammer "domain", "info", "--name", domain[:name]
	  test_result res

	  out = ShowOutput.new(res.stdout)

	  test "info output" do
	    out.matches?([
	      ['Organizations:', expected_organizations],
	    ])
	  end
	end
end


section "taxonomies" do
  section "general usage" do
    hammer "--csv", "organization", "create", @org_1
    hammer "--csv", "organization", "create", @org_2

    section "Admin" do
      section "one org no default" do
        hammer 'user', 'create', @admin_one_org_no_default
        
        section "created foreman resource has org set" do
          test_domain_creation(@admin_one_org_no_default, @domain, @org_1[:name])
        end
      end

    end

    section "Organization admin" do
      hammer 'role', 'clone', @one_org_admin_role
      hammer 'role', 'clone', @two_orgs_admin_role
      
      section "one org no default" do
        hammer 'user', 'create', @org_admin_one_org_no_default
        
        section "created foreman resource has org set" do
          test_domain_creation(@org_admin_one_org_no_default, @domain, @org_1[:name])
        end
      end

      section "one org default" do
        hammer 'user', 'create', @org_admin_one_org_default
        
        section "created foreman resource has org set" do
          test_domain_creation(@org_admin_one_org_default, @domain, @org_1[:name])
        end
      end

    end
  end
end

      



