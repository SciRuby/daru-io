RSpec.describe Daru::IO::Importers::RDS do
  subject { described_class.read(path).call }

  context 'reads data from bc_sites RDS file' do
    let(:path) { 'spec/fixtures/rds/bc_sites.rds' }

    it_behaves_like 'exact daru dataframe',
      ncols: 25,
      nrows: 1113,
      index: (0..1112).to_a,
      order: %i[
        state_or_province water_type sector region area location sub_location
        record_code format_version submission_date reporting_agency
        location_code location_type name latitude longitude psc_basin
        psc_region epa_reach description rmis_region rmis_basin rmis_latitude
        rmis_longitude record_origin
      ]
  end

  context 'reads data from chicago RDS file' do
    let(:path) { 'spec/fixtures/rds/chicago.rds' }

    it_behaves_like 'exact daru dataframe',
      ncols: 8,
      nrows: 6940,
      index: (0..6939).to_a,
      order: %i[
        city tmpd dptp date pm25tmean2 pm10tmean2 o3tmean2 no2tmean2
      ]
  end

  context 'reads data from healthexp RDS file' do
    let(:path) { 'spec/fixtures/rds/healthexp.Rds' }

    it_behaves_like 'exact daru dataframe',
      ncols: 6,
      nrows: 3030,
      index: (0..3029).to_a,
      order: %i[
        Country Region Year Population Life.Expectancy Health.Expenditure
      ]
  end

  context 'reads data from heights RDS file' do
    let(:path) { 'spec/fixtures/rds/heights.RDS' }

    it_behaves_like 'exact daru dataframe',
      ncols: 10,
      nrows: 3988,
      index: (0..3987).to_a,
      order: %i[
        id income height weight sex race education asvab sat_math bdate
      ]
  end

  context 'reads data from maacs_env RDS file' do
    let(:path) { 'spec/fixtures/rds/maacs_env.rds' }

    it_behaves_like 'exact daru dataframe',
      ncols: 27,
      nrows: 750,
      index: (0..749).to_a,
      order: %i[
        MxNum VisitNum pm25 no2 airnic coarse
        duBedWeight duBdRmWeight duKitchWeight
        duBedBlaG duBdRmBlaG duKitchBlaG
        duBedMusM duBdRmMusM duKitchMusM airmus
        duBedFelD duBdRmFelD duKitchFelD airFelD
        duBedCanF duBdRmCanF duKitchCanF airCanF
        duBedDerF duBdRmDerF duKitchDerF
      ]
  end

  context 'reads data from RPPdataConverted RDS file' do
    let(:path) { 'spec/fixtures/rds/RPPdataConverted.rds' }

    it_behaves_like 'exact daru dataframe',
      ncols: 138,
      nrows: 168,
      index: (0..167).to_a,
      order: %i[
        Local.ID Study.Title.O Authors.O Journal.O Volume.O Issue.O Pages.O
        Project.URL Descriptors.O Number.of.Authors.O Number.of.Authors.R
        1st.author.O Citation.Count.1st.author.O Institution.1st.author.O
        Senior.author.O Citation.count.senior.author.O
        Institution.senior.author.O 1st.author.R Citation.count.1st.author.R
        Institution.1st.author.R Senior.author.R Citation.count.senior.author.R
        Institution.senior.author.R Citation.count.paper.O
        Institution.prestige.1st.author.O Institution.prestige.senior.author.O
        Institution.prestige.1st.author.R Institution.prestige.senior.author.R
        Number.of.Studies.O Discipline.O Number.of.research.sites.O
        Secondary.data.O Methodology.expertise.required.O
        Opportunity.for.expectancy.bias.O Opportunity.for.lack.of.diligence.O
        Surprising.result.O Exciting.result.O
        Internal.conceptual.replications.O Successful.conceptual.replications.O
        Internal.direct.replications.O Successful.direct.replications.O
        Feasibility.O Status.R Completion.R Secondary.R Contact.Researcher.R
        Study.claim.date.R Analysis.completion.date.R Coder.s.email.R
        Replicated.study.number.R Test.statistic.O N.O Reported.P.value.O
        Calculated.P.value.O Tails.O Type.of.analysis.O.56 Type.of.effect.O
        Description.of.effect.O Effect.size.O Actual.Power.O 80.power 90.power
        95.power Collect.materials.from.authors Planned.Sample Planned.Power
        Original.Author.s.Assessment OSC.reviewer.O Test.statistic.R N.R
        P.value.R Direction.R Tails.R Type.of.analysis.R.74 Type.of.effect.R
        Replicate.R Power.R Effect.Size.R OSC.reviewer.R Notes.R
        Project.audit.complete.R R.check.location.R Degree.R
        Year.of.highest.degree.R Current.position.R Domain.expertise.R
        Method.expertise.R Total.publications.R Peer.reviewed.articles.R
        Citations.R Implementation.quality.R Data.collection.quality.R
        Replication.similarity.R Differences.R Effect.similarity.R
        Findings.similarity.R Difficulty.of.implimentation.R
        Surprise.of.outcome.R Dummy Number.of.Research.sites.R
        Secondary.data.R Area.of.expertise.R T.N.O T.Test.Statistic.O
        T.TestComparison.O T.df1.O T.df2.O T.Test.value.O T.p.comparison.O
        T.pval.O T.pval.recalc.O T.pval.USE.O T.sign.O.113 T.r.O T.N.R
        T.Test.Statistic.R T.Test.Comparison.R T.df1.R T.df2.R T.Test.value.R
        T.p.comparison.R T.pval.R T.pval.recalc.R T.pval.USE.R T.sign.R.125
        T.r.R T.Comparison.effects.R.O Type.of.analysis.O.128
        Type.of.analysis.R.129 V130 T.sign.O.131 T.sign.R.132 T.O.larger
        T.N.O.for.tables T.N.R.for.tables Meta.analytic.estimate.Fz
        O.within.CI.R Meta.analysis.significant
      ]
  end
end
