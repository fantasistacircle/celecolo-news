#!/bin/sh
# 本番のワールドが新しい置き場（origin）を読むようになるまでの橋渡し。
# 古い置き場（remote "old"）は bot の ranking.txt のコミットが積まれるので、ただの push は通らない。
# old/main の上に、いまの HEAD の news.txt と version.txt だけを重ねてコミットし、old へ上げる（ranking.txt は old のまま）。
# 古い方の鍵は gh に残っている古いアカウントの物を使う（画面・ログには出さない）。
cd "$(dirname "$0")" || exit 1
OLD_USER=$(git remote get-url old | sed 's#https://github.com/\([^/]*\)/.*#\1#')
OLD_TOK=$(gh auth token --user "$OLD_USER" 2>/dev/null) || { echo "sync-old: 古い置き場の鍵が gh に無い"; exit 1; }
export OLD_TOK
W="$(git rev-parse --git-dir)/sync-old-wt"
i=0
while [ $i -lt 3 ]; do
  i=$((i+1))
  git worktree remove --force "$W" >/dev/null 2>&1; rm -rf "$W"
  git fetch -q old main || { sleep 5; continue; }
  git worktree add -q --detach "$W" old/main || exit 1
  git show HEAD:news.txt > "$W/news.txt" && git show HEAD:version.txt > "$W/version.txt" || exit 1
  (
    cd "$W" || exit 1
    git add news.txt version.txt 2>/dev/null
    if git diff --cached --quiet; then echo "sync-old: 古い置き場はもう同じ"; exit 0; fi
    git commit -q -m "お知らせを写す（新しい置き場と同じ文）" || exit 1
    git -c credential.helper= -c credential.helper='!f(){ echo username=x-access-token; echo "password=$OLD_TOK"; }; f' push -q old HEAD:main && echo "sync-old: 古い置き場にも写しました"
  )
  r=$?
  git worktree remove --force "$W" >/dev/null 2>&1
  [ $r = 0 ] && exit 0
  sleep 5
done
echo "sync-old: 古い置き場に写せませんでした"; exit 1
