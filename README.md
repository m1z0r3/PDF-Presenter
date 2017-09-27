# 使い方

## build

```bash
docker-compose build
docker-compose run app bundle install
```

## スライドの準備
プレゼンしたいPDFファイルを `slides.pdf` という名前でルートに置く。
次に公開範囲を設定するテキストファイル `current.txt` を用意する。
公開したいページ数（0でなく1始まり）を書く。
3ページ目まで公開したい場合は

```
3
```

とだけ書く。

## スライド公開

```bash
docker-compose up
# up で起動中に current.txt を書き換える
echo 10 > current.txt
```

## スライドの見方

矢印キーの左または上で戻る、右または下で進む。
矢印キーを押す度に現在公開されているページを確認するので、公開範囲が変更された後は矢印キーを一度おした後に少し待ってから再度押すことで次のページに進める（適当に連打してもらえばよい）。