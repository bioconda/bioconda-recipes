from geenuff import orm
from sqlalchemy import Column, Integer, Float, ForeignKey, UniqueConstraint, CheckConstraint, String
from sqlalchemy.orm import relationship


class Mer(orm.Base):
    __tablename__ = "mer"

    id = Column(Integer, primary_key=True)
    coordinate_id = Column(Integer, ForeignKey('coordinate.id'), nullable=False)

    mer_sequence = Column(String, nullable=False)
    count = Column(Integer)
    length = Column(Integer)

    coordinate = relationship('orm.Coordinate')

    __table_args__ = (
        UniqueConstraint('mer_sequence', 'coordinate_id', name='unique_kmer_per_coord'),
        CheckConstraint('length(mer_sequence) > 0', name='check_string_gt_0'),
        CheckConstraint('count >= 0', name='check_count_gt_0'),
        CheckConstraint('length >= 1', name='check_length_gt_1'),
    )

    def __repr__(self):
        return '<Mer {}, coord_id: {}, seq: {}, count: {}, len: {}>'.format(self.id,
                                                                            self.coordinate_id,
                                                                            self.mer_sequence,
                                                                            self.count,
                                                                            self.length)

class MetaInformation(orm.Base):
    __tablename__ = "meta_information"

    id = Column(Integer, primary_key=True)
    genome_id = Column(Integer, ForeignKey('genome.id'), nullable=False)

    name = Column(String, nullable=False)
    value = Column(Float, nullable=False)

    genome = relationship('orm.Genome')

    __table_args__ = (
        UniqueConstraint('name', 'genome_id', name='unique_meta_info_per_genome'),
    )

    def __repr__(self):
        return '<MetaInformation {}, genome_id: {}, name: {}, value: {}>'.format(self.id,
                                                                                 self.genome_id,
                                                                                 self.name,
                                                                                 self.value)

