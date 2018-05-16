from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy
import cx_Oracle


# DB設定
def init_db(app):
    # Windows (note 3 leading forward slashes and backslash escapes)
    #app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///C:\\cygwin64\\home\\SCI00957\\sqlite3\\routeapi.db'
    #conn = cx_Oracle.connect("sci00957", "sci00957", "192.168.42.2:1521/XE")
    app.config['SQLALCHEMY_DATABASE_URI'] = 'oracle+cx_oracle://sci00957:sci00957@192.168.42.2:1521/?service_name=XE'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = True
    return SQLAlchemy(app)


app = Flask(__name__)
db = init_db(app)


# モデル定義
class User(db.Model):
    # テーブル名
    __tablename__ = "users"

    user_id = db.Column(db.String(10), primary_key=True)
    dept_no = db.Column(db.String(10))
    user_name = db.Column(db.String(10))
    created_on = db.Column(db.String(10))
    modified_on = db.Column(db.String(10))

    def to_dict(self):
        """
        全カラムをdictで返す
        :return:
        """
        return {'user_id': self.user_id,
                'dept_no': self.dept_no,
                'user_name': self.user_name,
                'created_on': self.created_on,
                'modified_on': self.modified_on
                }

    def __repr__(self):
        return '<User %r>' % self.user_id


@app.route("/")
def index():
    return "test"


# 全データ取得
@app.route("/routeapi/users", methods=['GET', 'POST'])
def users():
    print("debug:", User.query.all())
    return jsonify({'body': [User.to_dict(rec) for rec in User.query.all()]}), 200


# 特定ユーザ取得
@app.route("/routeapi/users/<user_id>", methods=['GET', 'POST'])
def show_user(user_id):
    print("debug:", User.query.filter_by(user_id=user_id).all())
    return jsonify({'body': [User.to_dict(rec) for rec in User.query.filter_by(user_id=user_id).all()]})


if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True)
