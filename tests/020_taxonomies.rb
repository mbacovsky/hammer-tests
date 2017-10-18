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
    :organizations => @one_org,
    :locations => "Default Location"
}

@one_org_manager_role = {
    :name => "Manager",
    :new_name => "One org manager #{IDX}",
    :organizations => @one_org,
    :locations => "Default Location"
}

@two_orgs_admin_role = {
    :name => "Organization admin",
    :new_name => "Two orgs admin #{IDX}",
    :organizations => @two_orgs,
    :locations => "Default Location"
}

@user_base = {
    :admin => false,
    :mail => "some.user@email.com",
    :password => "passwd",
    :auth_source_id => 1,
    :locations => "Default Location"
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

#---- common user
@user_one_org_no_default = @user_base.merge({
    :login => "user_one_org_no_default_#{IDX}",
    :roles => @one_org_manager_role[:new_name],
    :organizations => @one_org,
})

@user_one_org_default = @user_base.merge({
    :login => "user_one_org_default_#{IDX}",
    :roles => @one_org_manager_role[:new_name],
    :organizations => @one_org,
    :default_organization => @one_org
})



def new_domain
  @uniq_domain_counter ||= 0
  @uniq_domain_counter += 1
  {
      :name => "domain_#{IDX}_#{@uniq_domain_counter}"
  }
end

def new_product
  @uniq_product_counter ||= 0
  @uniq_product_counter += 1
  {
      :name => "product_#{IDX}_#{@uniq_product_counter}"
  }
end

def test_domain_creation(user, domain, expected_organizations)
  as_user(user[:login], user[:password]) do
    simple_test 'domain', 'create', domain

    res = hammer "domain", "info", "--name", domain[:name]
    test_result res

    out = ShowOutput.new(res.stdout)

    test "domain is within expected org" do
      out.column('Organizations') == expected_organizations
    end
  end
end

def test_product_creation(user, product, expected_organization)
  as_user(user[:login], user[:password]) do
    simple_test 'product', 'create', product

    res = hammer "product", "info", "--name", product[:name]
    test_result res

    out = ShowOutput.new(res.stdout)

    test "product is within expected org" do
      out.column('Organization') == expected_organization
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
          test_domain_creation(@admin_one_org_no_default, new_domain, @org_1[:name])
        end
      end
      
      section "one org default" do
        hammer 'user', 'create', @admin_one_org_default
  
        section "created foreman resource has org set" do
          test_domain_creation(@admin_one_org_default, new_domain, @org_1[:name])
        end
      end
    end

    section "Organization admin" do
      hammer 'role', 'clone', @one_org_admin_role
      hammer 'role', 'clone', @two_orgs_admin_role
      
      section "one org no default" do
        hammer 'user', 'create', @org_admin_one_org_no_default
        
        section "created foreman resource has org set" do
          test_domain_creation(@org_admin_one_org_no_default, new_domain, @org_1[:name])
        end
        
	section "created katello resource has org set" do
          test_product_creation(@org_admin_one_org_no_default, new_product, @org_1[:name])
        end
      end

      section "one org default" do
        hammer 'user', 'create', @org_admin_one_org_default
        
        section "created foreman resource has org set" do
          test_domain_creation(@org_admin_one_org_default, new_domain, @org_1[:name])
        end
	
	section "created katello resource has org set" do
          test_product_creation(@org_admin_one_org_default, new_product, @org_1[:name])
        end
      end
    end

    section "Common user" do
      hammer 'role', 'clone', @one_org_manager_role
      #hammer 'role', 'clone', @two_orgs_admin_role
      
      section "one org no default" do
        hammer 'user', 'create', @user_one_org_no_default
        
        section "created foreman resource has org set" do
          test_domain_creation(@user_one_org_no_default, new_domain, @org_1[:name])
        end
      end

      section "one org default" do
        hammer 'user', 'create', @user_one_org_default
        
        section "created foreman resource has org set" do
          test_domain_creation(@user_one_org_default, new_domain, @org_1[:name])
        end
      end
    end

  end
end

      



