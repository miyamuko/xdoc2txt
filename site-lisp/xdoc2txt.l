; -*- Mode: Lisp; Package: editor -*-

#|
= xdoc2txt - pdf, word, excel などの各種バイナリ文書からテキストを抽出

* Author:  MIYAMUKO Katsuyuki ((<URL:mailto:miyamuko@gmail.com>))
* URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/xdoc2txt/intro.htm>))
* Version: 0.8


== 説明

((<"xdoc2txt"|URL:http://www31.ocn.ne.jp/~h_ishida/xdoc2txt.html>)) を利用して
pdf, word, excel などの各種バイナリ文書からテキストを抽出して表示します。

* find-file-hooks に引っ掛けて実行しているので pdf などを xyzzy に D&D するだけで
  内容を閲覧できます。

* grep-dialog で pdf ファイルなどを開かずに grep できます。
  * ((<encap|URL:http://www.geocities.co.jp/SiliconValley-PaloAlto/5042/xyzzy/#encap>))
    が必要です。
  * ((<ggrep|URL:http://ohkubo.s53.xrea.com/xyzzy/#ggrep>))
    にも対応しています。

== インストール

((<NetInstaller|URL:http://www.mirai.ne.jp/~gyo/xyzzy/ni.html>)) でインストールした場合は
3 以降で OK です。

(1) アーカイブをダウンロードします。

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/xdoc2txt.zip>))

(2) アーカイブを展開して、$XYZZY/site-lisp 配下にファイルをコピーします。

(3) ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを追加します。

        ;; xdoc2txt
        (require "xdoc2txt")

    ※ggrep.l が存在する場合、勝手に require します。

(4) 設定を反映させるには xyzzy を再起動してください。

    ※siteinit.l に記述した場合には再ダンプが必要です。

(5) xdoc2txt をインストールした場所にパスを通すか、
    ((<*xdoc2txt-command*>)) で指定します。

(6) pdf ファイルなどを xyzzy で開きます。


== リファレンス

=== 変数

--- *xdoc2txt-command*
    xdoc2txt を実行するコマンドを指定します。デフォルトは xdoc2txt です。

    xdoc2txt.exe にパスを通していない場合に指定します。
    xdoc2txt.exe に渡すオプションは ((< *xdoc2txt-options* >)) で指定します。

    例:
        (setf *xdoc2txt-command* "C:/Program Files/d2txt120/xdoc2txt.exe")

--- *xdoc2txt-options*
    xdoc2txt.exe に渡すオプションを文字列 (またはリスト) で指定します。

    例:
        ;; xdoc2txt に渡すオプション
        ;;   -c:   PDF キャッシュ on
        ;;   -o=0: PDF で -- ? -- の形式のページ番号を表示しない
        ;; http://www31.ocn.ne.jp/~h_ishida/xdoc2txt.html
        (setf *xdoc2txt-options* "-c -o=0")

        ;; リスト形式でも可
        ; (setf *xdoc2txt-options* '("-c" "-o=0"))

--- *xdoc2txt-suffix*
    xdoc2txt で開くファイルの拡張子 (regexp) のリストです。

    デフォルト値は以下の通りです。(HTML 以外の xdoc2txt がサポートしているファイル)

        '("rtf" "doc" "xls" "ppt"
          "j[at]w" "j[bu]w" "j[fv]w" "jt[dt]"
          "oa[s23]"
          "bun"
          "wj[23]" "wk[34]" "123"
          "wri"
          "pdf")

--- *xdoc2txt-fold-width*
    xdoc2txt で開いたバッファのテキストの折り返し方法を制御します。

    set-buffer-fold-width の引数に指定します。

    * nil:
      折り返しません。(デフォルト)
    * t:
      ウィンドウの幅で折り返します。
    * 数値:
      折り返し位置を指定します。
    * 関数:
      ファイル名を引数に funcall した結果を設定します
      上記 3 つのどれかを返すようにしてください。

    例:

         ;; 80 文字で折り返す。
         (setf *xdoc2txt-fold-width* 80)

         ;; Word ファイルだけウィンドウ幅で折り返し
         (setf *xdoc2txt-fold-width* #'(lambda (filename)
                                         (if (string-matchp "\\.doc$" filename)
                                             t
                                           nil)))

--- *xdoc2txt-hook*
    xdoc2txt 実行後に実行されるフックです。grep-dialog のときも呼ばます。

    デフォルトでは以下のごみ掃除用のフックが登録されています。

    * 改行文字 (^M) の修正
    * 垂直タブ (^K) の展開
    * 行末の空白の削除

    run-hooks で実行されます。引数はありません。

    例:
        ;; pdf のページ番号を強調
        (defun highlight-pdf-page-number ()
          (make-local-variable 'regexp-keyword-list)
          (setf regexp-keyword-list
                (compile-regexp-keyword-list
                 `(("--[0-9]+/[0-9]+--" t ((0 . (:keyword 0))))))))
        (add-hook '*xdoc2txt-hook* 'highlight-pdf-page-number)

        ;; xdoc2txt で開いたときは view-mode にする
        (add-hook '*xdoc2txt-hook* 'view-mode)

== これからやるかもしれないこと

* xdoc2txt 本体を同梱する。

* make-process を使って体感速度の向上。

* 垂直タブの展開をまじめにする。

* 最初は undo できないように
  * clear-undo-boundary の使い方がよくわからん。
  * kept-undo-information を nil にするのが楽。
  * *xdoc2txt-hook* 後に一時ファイルに書き戻して
    もう一度 insert-file-content するか?

* コマンドの存在チェック。よりよいエラーメッセージ。


== 関連するかもしれないページ

: xdoc2txt PDF,WORD,EXCEL,一太郎などの各種バイナリ文書からテキストを抽出
    ((<URL:http://www31.ocn.ne.jp/~h_ishida/xdoc2txt.html>))


== ライセンス

xdoc2txt は修正 BSD ライセンスに基づいて利用可能です。

  Copyright (C) 2003-2006 MIYAMUKO Katsuyuki. All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1 Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer as the first lines
    of this file unmodified.

  2 Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
  OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
  SUCH DAMAGE.
|#

(provide "xdoc2txt")
(in-package "editor")

(export '(*xdoc2txt-command*
          *xdoc2txt-options*
          *xdoc2txt-suffix*
          *xdoc2txt-fold-width*
          *xdoc2txt-hook*))

(defvar *xdoc2txt-command* "xdoc2txt"
  "xdoc2txt.exe へのパス")

(defvar *xdoc2txt-options* nil
  "xdoc2txt.exe に渡すオプションのリスト")

(defvar *xdoc2txt-suffix*
  '("rtf" "doc" "xls" "ppt"
    "j[at]w" "j[bu]w" "j[fv]w" "jt[dt]"
    "oa[s23]"
    "bun"
    "wj[23]" "wk[34]" "123"
    "wri"
    "pdf"
;    "mht" "html"
    ))

(defvar *xdoc2txt-enable-p* t
  "xdoc2txt: non-nil にすると無効化")

(defvar *xdoc2txt-fold-width* nil
  "xdoc2txt: テキストの折り返し方法を制御します。
set-buffer-fold-width の引数に指定します。
 nil     折り返しません。
 t       ウィンドウの幅で折り返します。
 数値    折り返し位置を指定します。
 関数    ファイル名を引数に funcall した結果を設定します")

(defvar *xdoc2txt-hook* '(xdoc2txt-fix-cr-hook
                          xdoc2txt-fix-vt-hook
                          xdoc2txt-delete-trailing-spaces-hook)
  "xdoc2txt: フック。grep-dialog のときも呼ばれる。")

(defvar *xdoc2txt-vt-stop* 6)


(defun xdoc2txt-fold-width (filename)
  (if (functionp *xdoc2txt-fold-width*)
      (funcall *xdoc2txt-fold-width* filename)
    *xdoc2txt-fold-width*))

(defun xdoc2txt-command ()
  (map-slash-to-backslash *xdoc2txt-command*))

(defun xdoc2txt-options ()
  (if (listp *xdoc2txt-options*)
      *xdoc2txt-options*
    (list *xdoc2txt-options*)))

(defun xdoc2txt-file-regexp ()
  (format nil "\\.\\(~{~A~^\\|~}\\)$" *xdoc2txt-suffix*))

(defun xdoc2txt-file-matchp (filename)
  (string-matchp (xdoc2txt-file-regexp) filename))

(defun xdoc2txt-commandline (filename)
  (format nil "\"~A\" ~{ ~A~} \"~A\""
          (xdoc2txt-command)
          (xdoc2txt-options)
          (map-slash-to-backslash filename)))

(defun xdoc2txt (filename output &optional (temporary-p nil))
  (let ((fullpath (namestring filename))
        (tmpfile (make-temp-file-name)))
    (call-process (xdoc2txt-commandline fullpath)
                  :output tmpfile
                  :exec-directory (directory-namestring (xdoc2txt-command))
                  :show :minimize
                  :wait t)
    (unless (bufferp output)
      (setf output (or (find-buffer output)
                       (create-new-buffer output))))
    (set-buffer output)
    (xdoc2txt-with-temporary-writable
      (erase-buffer output)
      (insert-file-contents tmpfile t))
    (delete-file tmpfile)
    (xdoc2txt-setup-buffer filename (directory-namestring fullpath) temporary-p)))

(defun xdoc2txt-setup-buffer (filename defdir temporary-p)
  (xdoc2txt-with-selected-buffer
    (set-buffer (selected-buffer))
    (unless temporary-p
      (set-default-directory defdir)
      (set-buffer-fold-width (xdoc2txt-fold-width filename))
      (make-local-variable 'need-not-save)
      (setq need-not-save t))
    (run-hooks '*xdoc2txt-hook*)
    (update-visited-file-modtime)
    (set-buffer-modified-p nil)))


;;
;; util
;;

(defmacro xdoc2txt-with-temporary-writable (&rest body)
  `(let ((read-only buffer-read-only)
         (modified-p (buffer-modified-p)))
     (setf buffer-read-only nil)
     (unwind-protect
         (progn ,@body)
       (setf buffer-read-only read-only)
       (set-buffer-modified-p modified-p))))
(setf (get 'xdoc2txt-with-temporary-writable 'lisp-indent-hook) 0)

(defmacro xdoc2txt-with-selected-buffer (&body body)
  `(let ((#1=#:obuffer (selected-buffer)))
     (unwind-protect
         (progn ,@body)
       (set-buffer #1#))))
(setf (get 'xdoc2txt-with-selected-buffer 'lisp-indent-hook) 0)


;;
;; hook
;;

(defun xdoc2txt-fix-cr-hook ()
  ;; ppt なファイルだと改行が ^M (0x0D (CR (復帰))) で出力される場合がある。
  (save-excursion
    (xdoc2txt-with-temporary-writable
      (replace-buffer "\x0D" "\n"))))

(defun xdoc2txt-fix-vt-hook ()
  ;; ppt なファイルだとタイトル行の最後が ^K (0x0B (VT (垂直タブ))) になる場合がある。
  (save-excursion
    (xdoc2txt-with-temporary-writable
      (replace-buffer "\x0B" (make-sequence 'string *xdoc2txt-vt-stop* :initial-element #\LFD)))))

(defun xdoc2txt-delete-trailing-spaces-hook ()
  (save-excursion
    (xdoc2txt-with-temporary-writable
      (replace-buffer " +$" "" :regexp t))))

(defun xdoc2txt-find-file (filename)
  (interactive "lFind file: \n" :title0 "Find file")
  (when (get-file-buffer filename)
    (return-from xdoc2txt-find-file (get-file-buffer filename)))
  (xdoc2txt filename (file-namestring filename))
  (selected-buffer))

(defun xdoc2txt-enable-p (filename)
  (if (functionp *xdoc2txt-enable-p*)
      (funcall *xdoc2txt-enable-p* filename)
    *xdoc2txt-enable-p*))

(defun xdoc2txt-find-file-hook (filename)
  (when (and (xdoc2txt-enable-p filename)
             (xdoc2txt-file-matchp filename))
    (xdoc2txt-find-file filename)))

(defun xdoc2txt-add-before-find-file-hook ()
  (interactive)
  (add-hook '*before-find-file-hook* 'xdoc2txt-find-file-hook))

(defun xdoc2txt-delete-before-find-file-hook ()
  (interactive)
  (delete-hook '*before-find-file-hook* 'xdoc2txt-find-file-hook))

(xdoc2txt-add-before-find-file-hook)


;;
;; grep-dialog
;;

(defvar *xdoc2txt-shadow-grep-scanfn-p* t
  "xdoc2txt: scan-files-1 を shadow するかどうかのフラグ")

(defvar *xdoc2txt-shadow-scanfn-list* '((scan-files-1 . xdoc2txt-scan-files-1)
                                        (ggrep-scan-files-1 . xdoc2txt-ggrep-scan-files-1))
  "xdoc2txt: xdoc2txt-scan-files-1 で shadow する関数のリスト")

(defvar *xdoc2txt-required-lib-list* '("grep" "grepd" "ggrep")
  "xdoc2txt: 勝手に require するライブラリのリスト")

(defvar *xdoc2txt-tmp-buffer-name* "*xdoc2txt tmp*")

;; xdoc2txt 対応 scan-files-1。
(defun xdoc2txt-scan-files-1 (basic-definition file pattern buffer scanner)
  (unless (xdoc2txt-file-matchp file)
    (return-from xdoc2txt-scan-files-1
      (funcall basic-definition file pattern buffer scanner)))
  (save-excursion
    (xdoc2txt file buffer t)
    (goto-char (point-min))
    (message "scanning (~A)" file)
    (cond (*grep-name-only*
           (when (funcall scanner)
             (princ file)
             (terpri)
             t))
          (t
           (grep-scan-file file scanner)))))

;; xdoc2txt 対応 ggrep-scan-files-1。
(defun xdoc2txt-ggrep-scan-files-1 (basic-definition file patterns buffer scanner common-path &optional linenum-list)
  (unless (xdoc2txt-file-matchp file)
    (return-from xdoc2txt-ggrep-scan-files-1
      (funcall basic-definition file patterns buffer scanner common-path linenum-list)))
  (save-excursion
    (xdoc2txt file buffer t)
    (goto-char (point-min))
    (message "scanning (~A)" (subseq file (length common-path)))
    (cond (*ggrep-name-only* ;; linenum-list 無視
           (when (funcall scanner)
             (princ (subseq file (length common-path)))
             (terpri)
             t))
          (t
           (ggrep-scan-file file scanner common-path linenum-list)))))

(defun xdoc2txt-shadow-scan-files-1 ()
  (when (and (find-load-path "encap")
             *xdoc2txt-shadow-grep-scanfn-p*)
    (require "encap")
    (dolist (lib *xdoc2txt-required-lib-list*)
      (when (find-load-path lib)
        (require lib)))
    (dolist (pair *xdoc2txt-shadow-scanfn-list*)
      (when (fboundp (car pair))
        (xdoc2txt-encap-scan-files-1 (car pair) (cdr pair) 'xdoc2txt)))))

(defun xdoc2txt-encap-scan-files-1 (symbol wrapper type)
  (unless (encapsulated-p symbol type)
    (encapsulate symbol type
                 `((apply ',wrapper basic-definition argument-list)))))

;; scan-files-1 を xdoc2txt 対応に置き換える。
(xdoc2txt-shadow-scan-files-1)

;;
;; End of file
;;
