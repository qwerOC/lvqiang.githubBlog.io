####  git
```
# 创建本地分支
git branch 分支名称
# 创建本地分支并切换到该分支
git checkout -b 分支名称
# 远端存在子分支 本地创建分支并关联到该分支
git branch -b  本地分支名称 origin/远端分支名称
# 远端没有分支 本地有分支 远端创建分支并关联
git --set-upstream origin 远端分支名称

/// 删除某个分支 你不能在这个分支
# 删除本地分支
git branch -d 分支名称
# 删除远端分支
git push origin --delete 分支名称


/// 子分支合并
git checkout master /// 切换到主分支
git merge  要合并的分支名称
git push  ///和并完成推送到远端

/// 重置本地修改
git checkout .
/// 查看区别
git diff

=======

