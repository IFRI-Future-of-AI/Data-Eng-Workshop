from typing import List, Optional
import os

from fastapi import FastAPI, HTTPException, status, Depends
from pydantic import BaseModel
from sqlalchemy import Column, Integer, String, create_engine
from sqlalchemy.orm import declarative_base, sessionmaker, Session

# -----------------------
# Config (variable d'env)
# -----------------------
# Exemple: postgresql://user:password@localhost:5432/mydb
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:postgres@localhost:5432/postgres")

# -----------------------
# SQLAlchemy setup
# -----------------------
try :
    Base = declarative_base()
    engine = create_engine(DATABASE_URL, echo=False, future=True)
    SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False, expire_on_commit=False)

except Exception as e:
    print(f"Error creating engine: {e}")


class Person(Base):
    __tablename__ = "people"
    id = Column(Integer, primary_key=True, index=True)
    first_name = Column(String(length=150), nullable=False)
    last_name = Column(String(length=150), nullable=False)

# Create tables at startup (simple approach for demo)
Base.metadata.create_all(bind=engine)

# -----------------------
# Pydantic schemas
# -----------------------
class PersonCreate(BaseModel):
    first_name: str
    last_name: str

class PersonRead(PersonCreate):
    id: int

    class Config:
        orm_mode = True

# -----------------------
# FastAPI app
# -----------------------
app = FastAPI(title="Minimal People API")


# Dependency to get DB session
def get_db():
    db: Session = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/", response_model=dict)
def hello():
    return {"message": "Hello, world!"}


@app.post("/people", response_model=PersonRead, status_code=status.HTTP_201_CREATED)
def create_person(payload: PersonCreate, db: Session = Depends(get_db)):
    person = Person(first_name=payload.first_name.strip(), last_name=payload.last_name.strip())
    db.add(person)
    db.commit()
    db.refresh(person)
    return person


@app.get("/people", response_model=List[PersonRead])
def list_people(limit: Optional[int] = 100, db: Session = Depends(get_db)):
    items = db.query(Person).limit(limit).all()
    return items


@app.delete("/people/{person_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_person(person_id: int, db: Session = Depends(get_db)):
    person = db.get(Person, person_id)
    if not person:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Person not found")
    db.delete(person)
    db.commit()
    return None
