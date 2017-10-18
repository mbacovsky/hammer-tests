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
  :name => "domain #{IDX}"
}

section "taxonomies" do
  section "general usage" do
    hammer "--csv", "organization", "create", @org_1
    hammer "--csv", "organization", "create", @org_2

    section "Organization admin" do
      hammer 'role', 'create', @one_org_admin_role
      hammer 'role', 'create', @two_orgs_admin_role
      
      section "one org no default" do
        hammer 'user', 'create', @org_admin_one_org_no_default
        
        test "created foreman resource has org set" do
          user = @org_admin_one_org_no_default
          as_user(user[:login], user[:password]) do
            hammer 'domain', 'create', @domain
          end
        end
      end
    end
  end
end

      



