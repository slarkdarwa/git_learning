# git_learning
git learning from michaelliao
-(202010) nothing

git使用问题总结

1.清理/缓存账号信息，解决每次提交代码都要输入帐号和密码
git config --global --unset credential.helper
git config --global credential.helper store

2.编码模式设置，解决Windows环境和Uninx编码不一致
git config --global core.autocrlf false
git config --global core.filemode false
git config --global core.safecrlf true

3.设置忽略不生效
如果文件已经纳入了版本管理，那么修改 .gitignore 是不能失效的，解决方法如下：
	1）删除指定文件的缓存，命令行为：git rm -r --cached 文件路径\文件
	2）修改.gitignore文件，将需要忽略的文件或者文件夹加入
	3）提交.gitignore文件的修改

4.忽略文件修改 --skip-worktree
忽略	git update-index --skip-worktree <file>
取消忽略	git update-index --no-skip-worktree <file>

5.克隆仓库代码
克隆代码到指定路径	git clone <repo> <directory>
-> git clone http://xxx/xxx.git xxx
-> git clone http://xxx/xxx.git
-> git clone http://xxx/xxx.git
添加子模块	git submodule add A.git B
-> git submodule add http://xxx/xxx.git iesp-modules-common
-> git clone --recurse-submodules

6.分支管理
列出分支	git branch [--no-merged]
创建分支	git branch  <new-branch> [<existing-branch>/origin/<remotebranch>]
切换分支	git checkout <brachname>/<remotebranch>
硬重置远程分支 git reset --hard origin/＜branchname＞
-> git checkout develop
合并某分支到当前分支	git merge <brachname>
合并部分提交到当前分支	git cherry-pick <commitHash1> <commitHash2>
删除分支	git branch -d (branchname)
checkout历史记录	git reflog

7.本地有修改，但是不想提交又想切分支开发，操作方法如下：
	1）先暂存本地修改，命令行为：git stash
	2）切换到需要开发的分支，命令行为：git checkout 分支名
	3）在切换到的分支开发，开发完成后推送到gitlab
	4）切回之前的分支，命令行为：git checkout 分支名
	5）从暂存区恢复暂存的修改，命令行为：git stash pop
暂存最新no-commit-tracked	git stash [save] [stashname]
查看现有暂存 git stash list
恢复暂存 git stash apply [stashId]
恢复并删除暂存 git stash pop [stashId]
删除指定暂存	git stash drop [stashId]
删除全部暂存	git stash clear
查看暂存与当前差异	git stash show [-p] [stashId]
使用暂存创建分支	git stash branch <brachname>

8.代码提交
git commit -am "提交描述"

9.查看日志
查看提交记录	git log <option>
-> git log --graph
修改统计	git log --stat
修改统计	git whatchanged --stat 
过滤提交人	git log --author="author"
过滤文件	git log <file>
格式化提交记录(单行)	git log --oneline
格式化提交记录(文件列表)	git log --name-only
格式化提交记录(文件列表+操作)	git log --name-status
查看指定文件提交记录	git blame <file>
最后n次提交具体内容	git show <-n>
查看指定文件提交详情	git show <commitId> [file]

10.撤销文件修改
	1）未暂存，取消修改
	放弃某个文件修改	git checkout -- filename
	放弃所有文件修改	git checkout .
	2）已暂存未提交，取消暂存
	放弃某个文件修改	git reset HEAD filename
	放弃所有文件修改	git reset HEAD
	3）已提交
	回退到上一次commit的状态	git reset --hard HEAD^
	回退到任意版本	git reset --hard commit id
		
		

https://www.runoob.com/git/git-tutorial.html
https://www.csdn.net/tags/MtTagg5sOTg5NDUtYmxvZwO0O0OO0O0O.html
https://www.cnblogs.com/xy14/p/11104091.html
https://www.cnblogs.com/drizzlewithwind/p/5726911.html
https://blog.csdn.net/ZH_Pizi/article/details/106519065
https://blog.csdn.net/wang0907/article/details/121890014
https://mengqi92.github.io/2020/07/17/hide-files-from-git/
https://baijiahao.baidu.com/s?id=1709433232743585489&wfr=spider&for=pc
https://zhuanlan.zhihu.com/p/465954849
https://blog.csdn.net/qq_38425719/article/details/107792754
