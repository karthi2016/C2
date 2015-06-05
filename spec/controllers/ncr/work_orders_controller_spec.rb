describe Ncr::WorkOrdersController do
  describe 'creating' do
    before do
      login_as(FactoryGirl.create(:user))
    end
    let (:params) {{
      ncr_work_order: {
        amount: '111.22', expense_type: 'BA80', vendor: 'Vendor',
        not_to_exceed: '0', building_number: Ncr::BUILDING_NUMBERS[0],
        emergency: '0', rwa_number: 'A12345678', org_code: Ncr::ORG_CODES[0],
        code: 'Work Order', project_title: 'Title', description: 'Desc'},
      approver_email: 'bob@example.gov'
    }}

    it 'sends an email to the first approver' do
      post :create, params
      ncr = Ncr::WorkOrder.order(:id).last
      expect(ncr.code).to eq 'Work Order'
      expect(ncr.approvers.first.email_address).to eq 'bob@example.gov'
      expect(email_recipients).to eq(['bob@example.gov', ncr.requester.email_address].sort)
    end

    it 'does not error on missing attachments' do
      params[:ncr_work_order][:amount] = '111.33'
      params[:attachments] = []
      post :create, params
      ncr = Ncr::WorkOrder.order(:id).last
      expect(ncr.amount).to eq 111.33
      expect(ncr.proposal.attachments.count).to eq 0
    end

    it 'does not error on malformed attachments' do
      params[:ncr_work_order][:amount] = '111.34'
      params[:attachments] = 'abcd'
      post :create, params
      ncr = Ncr::WorkOrder.order(:id).last
      expect(ncr.amount).to eq 111.34
      expect(ncr.proposal.attachments.count).to eq 0
    end

    it 'adds attachments if present' do
      params[:ncr_work_order][:amount] = '111.35'
      params[:attachments] = [
        fixture_file_upload('icon-user.png', 'image/png'),
        fixture_file_upload('icon-user.png', 'image/png'),
      ]
      post :create, params
      ncr = Ncr::WorkOrder.order(:id).last
      expect(ncr.amount).to eq 111.35
      expect(ncr.proposal.attachments.count).to eq 2
    end
  end

  describe 'editing' do
    let (:work_order) { FactoryGirl.create(:ncr_work_order, :with_approvers) }
    before do
      login_as(work_order.proposal.requester)
    end

    it 'does not modify the work order when there is a blank approver' do
      post :update, {id: work_order.id, approver_email: '',
                     ncr_work_order: {expense_type: 'BA61', name: 'new name'}}
      expect(flash[:success]).not_to be_present
      expect(flash[:error]).to be_present
      work_order.reload
      expect(work_order.name).not_to eq('new name')
    end

    it 'does not modify the work order when there is a bad edit' do
      post :update, {id: work_order.id, approver_email: 'a@b.com',
                     ncr_work_order: {expense_type: 'BA61', amount: 999999}}
      expect(flash[:success]).not_to be_present
      expect(flash[:error]).to be_present
      work_order.reload
      expect(work_order.amount).not_to eq(999999)
    end

    it 'allows the approver to be edited' do
      post :update, {id: work_order.id, approver_email: 'a@b.com',
                     ncr_work_order: {expense_type: 'BA61'}}
      work_order.reload
      expect(work_order.approvers.first.email_address).to eq('a@b.com')
    end

    it 'does not modify the approver if already approved' do
      work_order.proposal.approvals.first.approve!
      post :update, {id: work_order.id, approver_email: 'a@b.com',
                     ncr_work_order: {expense_type: 'BA61'}}
      work_order.reload
      expect(work_order.approvers.map(&:email_address)).not_to include('a@b.com')
    end
  end
end
