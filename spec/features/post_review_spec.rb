require 'rails_helper'

RSpec.feature "PostReview", type: :feature do
  let(:user) { create(:user) }
  let(:adminuser) { create(:user, admin: true) }

  scenario "未ログインユーザーで、お店に口コミを投稿する" do
    search

    # 遷移先に口コミ投稿フォームがあることを確認
    expect(page).to have_css(".new_review")

    # 遷移先に口コミ欄開閉のreviews__op-clクラスがないことを確認
    expect(page).not_to have_css(".reviews__op-cl")

    post_review(nil)

    # 口コミが追加されていることを確認
    within("#review-1") do
      expect(page).not_to have_content "削除する"
      within(".reviews__user") do
        expect(page).to have_content "ゲスト"
      end
      within(".reviews__body") do
        expect(page).to have_content "口コミテスト"
      end
    end
  end

  scenario "ログイン済ユーザーで、お店に口コミを投稿する" do
    login(user, "testuser")
    search

    # 遷移先に口コミ投稿フォームがあることを確認
    expect(page).to have_css(".new_review")

    # 遷移先に口コミ欄開閉のreviews__op-clクラスがないことを確認
    expect(page).not_to have_css(".reviews__op-cl")

    post_review(user.id)

    # 口コミが追加されていることを確認
    within("#review-1") do
      expect(page).not_to have_content "削除する"
      within(".reviews__user") do
        expect(page).to have_content user.username
      end
      within(".reviews__body") do
        expect(page).to have_content "口コミテスト"
      end
    end
  end

  scenario "管理者ユーザーで、お店に口コミを投稿する" do
    login(adminuser, "testuser")

    search

    # 遷移先に口コミ投稿フォームがあることを確認
    expect(page).to have_css(".new_review")

    # 遷移先に口コミ欄開閉のreviews__op-clクラスがないことを確認
    expect(page).not_to have_css(".reviews__op-cl")

    post_review(user.id)

    # 口コミが追加されていることを確認
    within("#review-1") do
      expect(page).to have_content "削除する"
      within(".reviews__user") do
        expect(page).to have_content user.username
      end
      within(".reviews__body") do
        expect(page).to have_content "口コミテスト"
      end
    end

    click_on "削除する"

    expect(page).to have_http_status :ok

    expect(page).not_to have_text("口コミを見る")
  end
end
